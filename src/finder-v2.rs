fn main() {
    for entry in std::fs::read_dir("/home/emil/luzz/dependencies").unwrap() {
    let entry = entry.unwrap(); 
    let name = entry.file_name();
 //   println!("{:?}", name);     
        if entry.path().join(".dp").exists(){
            println!("{:<10} {:<30} {:<10}", "C", name.to_string_lossy(), "Stopped",);
        }
    }   
}