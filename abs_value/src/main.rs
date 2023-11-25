fn main() {
    
    let res = abs_value_iter(vec![-1.4, 2.6, -3.2]);
    println!("this is {}", res[0])
}

fn abs_value(x: f64) -> f64 {
    let number = if x>=0.0 { x } else { -1.0 * x };
    return number;
}

fn abs_value_iter(v: Vec<f64>) -> Vec<f64> {
    let abs_v: Vec<_> = v.iter().map(|x| abs_value(*x)).collect();
    return abs_v;
}
