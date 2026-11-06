mod finder;
mod builder;
mod lifecycle;

fn main() {
    let args: Vec<String> = std::env::args().collect();
    if args.len() < 2{
        println!("[X] Error! Use luzz run <target_name> or luzz check to see a fuzzing targets");
        return;
    }
    match args[1].as_str(){
    "check" =>  finder::list_components(),
    
    "run" if args.len() < 3         => println!("Error! Enter the target name"),
    "run" if args.len() == 3        => builder::builder(&args[2]),
    "lifecycle" if args.len() <3    => println!("Error! Enter the target to check lifecycle status "),
    "lifecycle"                     => lifecycle::docker_lifecycle(&args[2]),
    _                               => println!("Unknown command")
    }
}
