use std::process::Command;
pub fn builder(target: &str){
    let path = format!("dependencies/{target}");

    let dp_path = format!("{path}/.dp");
    if std::path::Path::new(&dp_path).exists(){
        Command::new("docker")
        .args(&["build", "-t", target, &path ])
        .status().unwrap();
    
    } else {
        println!("[X] Error! Target doesn`t exist.")
    }
}