mod finder;
mod builder;


fn main() {
    let args: Vec<String> = std::env::args().collect();
    if args.len() < 2{
        println!("error");
        return;
    }
    match args[1].as_str(){
    "check" =>  finder::list_components(),
    "run" if args.len() < 3 => println!("Error! <run> only more than 3 arguments"),
    "run" if args.len() == 3 => builder::builder(&args[2]),
    _ => println!("Unknown command")
    }
}
// больше логов с момента старта до момента запуска
// количество использованных (запущенных) ручек 
// количество использованных корпусов
// количество использованных харнес
