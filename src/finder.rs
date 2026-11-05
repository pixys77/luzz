pub fn list_components(){
    println!("{:<10} {:>20}", "Component name", "Language:");
    println!("------------------------------------");

    for entry in std::fs::read_dir("/home/emil/luzz/dependencies").unwrap() {
    let entry = entry.unwrap(); 
    let dp_path = entry.path().join(".dp");
    let name = entry.file_name();
      
        if dp_path.exists(){
            let mut read_file = std::fs::read_to_string(dp_path);
            let read_file = read_file.unwrap();
            let mut language = "Undefined";
            for line in read_file.lines(){
                if let Some(val) = line.strip_prefix("language=") {language = val;}
            }
            println!("{:<20} {:>10}", name.to_string_lossy(), language);
            

            
            
        }
    }   
}