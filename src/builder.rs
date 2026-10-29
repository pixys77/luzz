use std::process::Command;
use std::process::Stdio;


fn main() {
    run_docker_version();
    call_run_docker_fn();
}


fn run_docker_run(name: &[&str]){
    let docker_command = Command::new("docker")
        .args(name)
        .status()
        .expect("error");
    println!("Код завершения:{}", docker_command.code().unwrap_or(-1));
}

fn call_run_docker_fn(){
    run_docker_run(&["run", "-i", "--rm", "alpine:latest"]);
}

fn run_docker_version(){
    let docker_command = Command::new("docker")
        .arg("version")
        .stdout(Stdio::null())
        .status()
        .expect("Error, Docker not found");
    if !docker_command.success() {
        std::process::exit(1);
    }
}
