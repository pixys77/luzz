enum Event {
    Key(KeyEvent),       
    Mouse(MouseEvent),   
    Resize(u16, u16),    
 
}

let mut counter = 0;

loop {
    println!("Счетчик равен: {}", counter);
    counter += 1;

    // Условие выхода
    if counter == 3 {
        break; // СТОП! Выходим из loop
    }
}

println!("Цикл закончился, идем дальше!");