// колесо Лейбница
// https://en.wikipedia.org/wiki/Leibniz_wheel
// по мотивам макета:
// https://www.youtube.com/watch?v=H1nz7kMfkMU
// author: Anton Moiseev, 2023

// https://github.com/sadr0b0t/pd-gears
use <pd-gears/pd-gears.scad>

// погрешность печати - компенсация диаметра
// сопла 3д-принтера
print_error=0.1;
$fn=100;

// для ранних версий диаметр валов варьировался,
// переменные оставил, но остальные части модели
// могут учитывать другие значения, кроме тех, которые
// здесь указаны (короче, переменные пусть будут,
// но лучше не менять эти значения)
out_digit_wheel_rod_r = 4.5;
stepper_drum_rod_r = 4.5;
input_digit_wheel_rod_r = 4.5;

// отдельные детали - экспорт для 3д-печати
//out_digit_wheel();
//out_digit_gear();
//out_digit_rod();
//out_digit_fixer();
//stepper_drum();
//stepper_drum_driving_rod();
//stepper_drum_rack_rod();
//stepper_drum_rack();
//adder_box();
//out_digit_fixer();
//input_digit_wheel();
//input_digit_gear();
//input_digit_rod();
//input_digit_rod_base();
//input_digit_fixer();

// узлы в сборке
//out_digit_with_rod();
//stepper_drum_with_rods();
//input_digit_with_rod();

// полная сборка
rotate([0, 90, 0]) leibniz_adder(
   input_val=0, out_val=0, stepper_drum_angle=0, draw_out_digit_fixer=true);

// полная сборка - демо по шагам
//rotate([0, 90, 0]) leibniz_adder(
//    input_val=0, out_val=0, stepper_drum_angle=-60);
//    input_val=1, out_val=0, stepper_drum_angle=-60);
//    input_val=2, out_val=0, stepper_drum_angle=-60);
//    input_val=3, out_val=0, stepper_drum_angle=-60);
//    input_val=4, out_val=0, stepper_drum_angle=-60);
//    input_val=5, out_val=0, stepper_drum_angle=-60);
//    input_val=6, out_val=0, stepper_drum_angle=-60);
//    input_val=7, out_val=0, stepper_drum_angle=-60);
//    input_val=8, out_val=0, stepper_drum_angle=-60);
//    input_val=9, out_val=0, stepper_drum_angle=-60);
//    input_val=0, out_val=0, stepper_drum_angle=0);
//    input_val=3, out_val=0, stepper_drum_angle=0);
//    input_val=3, out_val=0, stepper_drum_angle=220);
//    input_val=3, out_val=3, stepper_drum_angle=286);
//    input_val=3, out_val=3, stepper_drum_angle=360);
//    input_val=5, out_val=3, stepper_drum_angle=0);
//    input_val=5, out_val=3, stepper_drum_angle=180);
//    input_val=5, out_val=8, stepper_drum_angle=285);
//    input_val=5, out_val=8, stepper_drum_angle=360);
//    input_val=0, out_val=8, stepper_drum_angle=0);

////////////////////////////////////////////////////////////
// колесо с цифрами разряда - результат сложения
module out_digit_wheel(color_digit=[0.7, 0.3, 0.1], color_wheel=[1, 1, 1]) {
    difference() {
        union() {
            // малый цилиндр - выступ между стенкой
            color(color_wheel)
                cylinder(r=out_digit_wheel_rod_r+3, h=11);
            // основной цилиндр
            color(color_wheel)
                cylinder(r=15, h=10);
            
            for(i=[0 : 9]) {
                a = i*360/10;
                color(color_digit)
                rotate ([0, 0, a]) translate([-3, -15+1, 1.5])
                    rotate([90, 0, 0]) linear_extrude(2) text(str(i), size=7);
            }
        }
        
        translate([0, 0, -0.1])
            cylinder(r=out_digit_wheel_rod_r+print_error, h=11+0.2);
    }
}

// поворотная шестеренка разряда
module out_digit_gear() {
    difference() {
        // диаметр примерно 30мм
        // cylinder(r=15, h=1);    
        gear(mm_per_tooth=8, pressure_angle=20,
                    number_of_teeth=10, thickness=5-1,
                    hole_diameter=out_digit_wheel_rod_r*2+print_error*2,
                    center=false, $fn=$fn);
        
        translate([0, 0, -0.1])
            cylinder(r=out_digit_wheel_rod_r+print_error, h=5-1+0.2);
    }
}

module out_digit_rod() {
    // центральная ось
    cylinder(r=out_digit_wheel_rod_r-0.2-print_error, h=100+1+2+6+4);
    
    // стержень потоньше, иначе шестеренка и колесо
    // не налезут совсем
    translate([0, 0, 100+1+2+6+4-2])
        cylinder(r=out_digit_wheel_rod_r+3, h=2);
}

module out_digit_with_rod() {
    // поворотная шестеренка разряда
    translate([0, 0, 45+1])
        out_digit_gear();
    
    // колесо с цифрами разряда
    translate([0, 0, 90+1]) out_digit_wheel();

    // центральная ось
    translate([0, 0, -6])
        out_digit_rod();
}

// пружинка, фиксирующая результирующий разряд
module out_digit_fixer() {
    translate([0, 0, 0]) cube([1.5, 15, 5]);
    translate([0.75, 15, 0]) cylinder(r=1.5, h=5);
    
    translate([0, 0, 0]) cube([66, 3, 5]);
    translate([66, 0, 0]) cube([3, 40, 5]);  
}

// складывающее колесо (колесо Лейбница)
// со ступенькой из зубов шестеренки
module stepper_drum() {
    difference() {
        gear(mm_per_tooth=8, pressure_angle=20,
                    number_of_teeth=18, thickness=45,
                    hole_diameter=0,
                    center=false, $fn=$fn);
        
        // срезаем 9 зубов ступенькой
        for(i=[0 : 9]) {
            a = i*360/18;
            rotate ([0, 0, -a]) translate([-5, 20.25, 5*i]) cube([10, 10, 45.2]);
        }
        
        // срезаем остальные 9 зубов просто так
        for(i=[10 : 18]) {
            a = i*360/18;
            rotate ([0, 0, -a]) translate([-5, 20.25, -0.1]) cube([10, 10, 45.2]);
        }
        
        // вырезать отверстие для стержня с полостью внутри
        // для зацепа
        // (альтернатива: встроить по краям подшипники
        // и вставить плотно стержень в них)
        translate([0, 0, -0.1])
            cylinder(r=stepper_drum_rod_r+print_error, h=42+0.1);
        // полость для зацепа "ключа"
        translate([0, 0, 38])
            cylinder(r=stepper_drum_rod_r+5+print_error, h=4+0.1);
        // площадка для крышки сверху
        translate([0, 0, 42]) cylinder(r=19+print_error, h=3.1);
    }
}

// стержень с поворотной ручкой
module stepper_drum_driving_rod() {
    difference() {
        union() {
            // крышка для складывающего колеса
            cylinder(r=19-print_error, h=3);
            
            // ось-трубка (внутрь крышки войдет конец
            // другого стержня)
            cylinder(r=stepper_drum_rod_r+2, h=80);
            
            // ручка
            translate([5, -1.5, 80-8]) cube([7, 3, 8]);
        }
        
        translate([0, 0, -0.1])
            cylinder(r=stepper_drum_rod_r+print_error, h=80+0.2);
    }
}

// стержень с рейкой
module stepper_drum_rack_rod() {
    
    difference() {
        // срежем дополнительно 0.5 мм от радиуса,
        // чтобы стержень входил в колесо не враспор
        cylinder(r=stepper_drum_rod_r-0.5-print_error, h=110);
        
        // площадка под рейку
        translate([-stepper_drum_rod_r, -stepper_drum_rod_r, -0.1])
            cube([stepper_drum_rod_r*2,  stepper_drum_rod_r, 60+0.1]);
    }
    
    // "ключ" - зацеп внутри колеса
    // стержень выступает наружу на высоту крышки
    // диаметр цилиндра-ключа минус 1мм,
    // высота - минус 0.5 мм, чтобы не враспор
    translate([0, 0, 110-4-7])
        cylinder(r=stepper_drum_rod_r+5-1-print_error, h=4-0.5);
}

// рейка для стержня с рейкой
module stepper_drum_rack() {
    // рейка
    // mm_per_tooth должно быть кратно высоте ступеньки
    // складывающего колеса для удобства
    rack(
            mm_per_tooth=5,
            number_of_teeth=12,
            height=5, 
            thickness=stepper_drum_rod_r*2-print_error*2);
}

module stepper_drum_with_rods(rot_angle=0) {
    rotate([0, 0, rot_angle]) stepper_drum();
    
    translate([0, 0, 42]) rotate([0, 0, rot_angle]) stepper_drum_driving_rod();
    
    translate([0, 0, -55-3-1-2]) union() {
        stepper_drum_rack_rod();
        translate([-stepper_drum_rod_r+print_error, -3, 1])
            rotate([0, -90, 180]) stepper_drum_rack();
    }
}

module adder_box() {
    difference() {
        union() {
            // дно
            // внутренняя высота:
            //   100 мм - базовая
            //   +1мм - отступ для складывающего колеса
            //   +2мм - отступы для колеса со значениями разряда
            //   +6мм - толщина 2-х стенок
            translate([30, -20/2, -3-1]) cube([3, 20, 100+1+2+6]);
            // боковые стенки
            translate([-45, -20/2, -3-1]) cube([75, 20, 3]);
            translate([-45, -20/2, 100+2]) cube([75, 20, 3]);
            
            // отступ между стенкой и складывающим колесом
            translate([0, 0, -3-1])
                cylinder(r=stepper_drum_rod_r+3, h=4);
        }
        
        // вычитаем отверстия
        
        // стержень - складывающее колесо - часть с рейкой
        translate([0, 0, -3-1-0.1])
            cylinder(r=stepper_drum_rod_r+print_error, h=3+1+0.2);
        translate([-stepper_drum_rod_r-print_error, -5.5, -3-1-0.1])
            cube([stepper_drum_rod_r*2+print_error*2, 5.5, 3+1+0.2]);
        
        // стержень - складывающее колесо - поворотная ручка
        translate([0, 0, 100+2-0.1])
            cylinder(r=stepper_drum_rod_r+2+print_error, h=3+0.2);
        
        // стержень - колесо со значением разряда
        translate([-38, 0, -3-1-0.1])
            cylinder(r=out_digit_wheel_rod_r+print_error, h=100+1+2+6+0.2);
    }
}

module input_digit_wheel(color_digit=[0.7, 0.3, 0.1], color_wheel=[1, 1, 1]) {
    difference() {
        union() {
            color(color_wheel)
                cylinder(r=15, h=3);
            
            for(i=[0 : 9]) {
                a = i*360/10;
                color(color_digit)
                rotate ([0, 0, a]) translate([-3, -15+1, 0])
                    linear_extrude(4) text(str(i), size=6);
            }
        }
        
        translate([0, 0, -0.1])
            cylinder(r=input_digit_wheel_rod_r+print_error, h=2+0.2);
    }
}

module input_digit_gear() {
    difference() {
        // диаметр примерно 30мм
        // cylinder(r=15, h=1);    
        gear(mm_per_tooth=5, pressure_angle=20,
                    number_of_teeth=10, thickness=8,
                    hole_diameter=input_digit_wheel_rod_r*2+print_error*2,
                    center=false, $fn=$fn);
        
        // отверстие пошире, иначе не налезет на ось (стержень)
        // даже с учетом погрешности печати
        translate([0, 0, -0.1])
            cylinder(r=input_digit_wheel_rod_r+0.2+print_error, h=8+0.2);
    }
}

module input_digit_rod() {
    cylinder(h=80, r=input_digit_wheel_rod_r-print_error);
}

// 
module input_digit_rod_base() {
    difference() {
        union() {
            cylinder(h=20, r=input_digit_wheel_rod_r+3.5);
            translate([0, 3, 0]) cube([16, 5, 20]);
            translate([13, 3, 0]) cube([3, 20, 20]);
        }
        
        translate([0, 0, 3])
            cylinder(h=17.1, r=input_digit_wheel_rod_r+0.5-print_error);
    }
}

// пружинка, фиксирующая входной разряд
module input_digit_fixer() {
    difference() {
        cylinder(r=8.5, h=8);
        
        translate([-8.5, 0, -0.1]) cube([70, 40, 8.5+0.2]);
        translate([0, 0, -0.1]) cylinder(r=8.5-1.5, h=8.5+0.2);
    }
    
    //translate([8.5-1.5, 0, 0]) cube([1.5, 33, 8]);
    translate([8.5-1.5, 0, 0]) cube([1.5, 17, 8]);
    translate([-7.5, 0, 0]) cylinder(r=1.5, h=8);
}

module input_digit_with_rod(input_val=0) {
    rotate([0, 0, -36*input_val])
    translate([0, 0, 83]) input_digit_wheel();
    translate([0, 0, 29]) rotate([0, 0, 16]) input_digit_gear();
    
    translate([0, 0, 3]) cylinder(h=80, r=input_digit_wheel_rod_r-print_error);
    
    input_digit_rod_base();
    
    translate([7.5, -10, 29]) input_digit_fixer();
}

// @param input_val - 0-9
// @param out_val - 0-9
// @param stepper_drum_angle 0-360
module leibniz_adder(input_val=0, out_val=0, stepper_drum_angle=0,
        draw_out_digit_fixer=false) {
    adder_box();
    if(draw_out_digit_fixer) {
        translate([-39, -30, 45]) out_digit_fixer();
    }
    translate([-38, 0, 0]) rotate([0, 0, -90-36*out_val]) out_digit_with_rod();
    
    translate([33, -13, -20]) rotate([0, -90, 0])
        input_digit_with_rod(input_val=input_val);
    translate([0, 0, 5*input_val])
        stepper_drum_with_rods(rot_angle=stepper_drum_angle);
}

