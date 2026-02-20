use log::{debug, error};
use std::env;
use std::path::PathBuf;
use std::process::{exit, Command};

#[cfg(test)]
use mockall::automock;

const PROJECTS: &[(&str, &str)] = &[
    ("agent", "dd/datadog-agent"),
    ("lading", "dd/lading"),
    ("smp", "dd/single-machine-performance"),
    ("weasel", "dev/weasel"),
    ("bench", "dev/bench"),
    ("notes", "notes"),
];

fn find_matching_project(input: &str) -> Option<(&'static str, &'static str)> {
    let matches: Vec<(&str, &str)> = PROJECTS
        .iter()
        .filter(|(name, _)| name.starts_with(input))
        .copied()
        .collect();

    match matches.len() {
        0 => {
            error!("Project '{}' not found", input);
            error!("Available projects:");
            for (name, _) in PROJECTS {
                error!("  - {}", name);
            }
            None
        }
        1 => Some(matches[0]),
        _ => {
            error!("Ambiguous input '{}'. Multiple matches found:", input);
            for (name, _) in matches {
                error!("  - {}", name);
            }
            None
        }
    }
}

// Trait for system operations
#[cfg_attr(test, automock)]
trait SystemOps {
    fn get_home(&self) -> PathBuf;
    fn run_command(&self, cmd: String, args: Vec<String>) -> Result<(), String>;
}

fn get_home() -> PathBuf {
    let home = env::var("HOME").expect("HOME environment variable not set");
    PathBuf::from(home)
}

// Real implementation that executes commands
struct RealSystemOps;

impl SystemOps for RealSystemOps {
    fn get_home(&self) -> PathBuf {
        get_home()
    }

    fn run_command(&self, cmd: String, args: Vec<String>) -> Result<(), String> {
        let status = Command::new(&cmd)
            .args(&args)
            .current_dir(self.get_home())
            .status();

        match status {
            Ok(status) if status.success() => Ok(()),
            Ok(_) => Err(format!("Command failed: {} {:?}", cmd, args)),
            Err(e) => Err(format!("Failed to execute: {}", e)),
        }
    }
}

// Dry-run implementation that prints instead of executing
struct DryRunSystemOps;

impl SystemOps for DryRunSystemOps {
    fn get_home(&self) -> PathBuf {
        get_home()
    }

    fn run_command(&self, cmd: String, args: Vec<String>) -> Result<(), String> {
        println!("{} {}", cmd, args.join(" "));
        Ok(())
    }
}

fn is_dry_run() -> bool {
    env::var("DRY_RUN").is_ok()
}

// Main logic with injected dependencies
fn open_vscode(relative_path: &str, sys: &dyn SystemOps) {
    // Use code command via login shell to get proper environment
    let abs_path = sys.get_home().join(relative_path);
    let path_str = abs_path.to_string_lossy().to_string();
    let cmd = format!("code '{}'", path_str);

    debug!("Opening VSCode for: {}", path_str);

    match sys.run_command(
        "/bin/zsh".to_string(),
        vec!["-l".to_string(), "-c".to_string(), cmd],
    ) {
        Ok(_) => {}
        Err(e) => {
            error!("Failed to open VSCode: {}", e);
            exit(1);
        }
    }
}

fn main() {
    env_logger::init();

    let args: Vec<String> = env::args().collect();

    if args.len() != 2 {
        error!("Usage: {} <project-name>", args[0]);
        exit(1);
    }

    let input = &args[1];

    let relative_path = match find_matching_project(input) {
        Some((name, relpative_path)) => {
            debug!("Matched '{}' to '{}'", input, name);
            relpative_path
        }
        None => exit(1),
    };

    // Create the appropriate SystemOps implementation based on environment
    let real_sys = RealSystemOps;
    let dry_sys = DryRunSystemOps;
    let sys: &dyn SystemOps = if is_dry_run() { &dry_sys } else { &real_sys };

    open_vscode(relative_path, sys);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_project_matching() {
        assert_eq!(
            find_matching_project("weasel"),
            Some(("weasel", "dev/weasel"))
        );
        assert_eq!(find_matching_project("w"), Some(("weasel", "dev/weasel")));
        assert_eq!(
            find_matching_project("ag"),
            Some(("agent", "dd/datadog-agent"))
        );
        assert_eq!(find_matching_project("tnhoushtoeu"), None);
    }

    #[test]
    fn test_open_vscode_wraps_in_login_shell() {
        let mut mock = MockSystemOps::new();
        mock.expect_get_home()
            .return_const(PathBuf::from("/Users/test"));
        mock.expect_run_command()
            .withf(|cmd, args| {
                cmd == "/bin/zsh"
                    && args.len() == 3
                    && args[0] == "-l"
                    && args[1] == "-c"
                    && args[2] == "code '/Users/test/dev/project'"
            })
            .return_const(Ok(()));

        open_vscode("dev/project", &mock);
    }
}
