use std::process::Command;
use std::process::Stdio;


fn main() {
    get_finder();
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
        .status();

    match docker_command {
        Ok(status) => {
            println!("success");
        } 
        Err(error) => {
            println!("Error");
        }
    }
}

fn get_finder() {
    let finder_command = Command::new("luajit")
    .arg("finder.lua")
    .output();
    match finder_command {
        Ok(output) => {
            println!("{}", String::from_utf8_lossy(&output.stdout));
        }
        Err(error) => {
            println!("Error");
        }


    }

}