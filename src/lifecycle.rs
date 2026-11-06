use std::process::Command;

pub fn docker_lifecycle(target: &str){
    let container_name = format!("luzz-{target}");
    let checker = Command::new("docker")
                .args(["inspect", "-f", "{{.State.Status}}", &container_name])
                .output().unwrap();
    let output_check = String::from_utf8_lossy(&checker.stdout);
    match output_check.trim(){
        "running"       => println!("Service is running"),
        "exited"        => println!("Service stopped"),
        "paused"        => println!("Docker Paused"),
        "restarting"    => println!("Docker restarted"),
        "created"       => println!("Docker created"),
        "dead"          => println!("Container isDead"),
        _               => println!("unknown error")

    }




}

