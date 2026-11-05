use std::process::Command;
pub fn builder(target: &str){
    let path = format!("dependencies/{target}");
    Command::new("docker")
    .args(&["build", "-t", target, &path ])
    .status().unwrap();
}