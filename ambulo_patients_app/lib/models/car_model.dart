class Car {
  final String name;
  final String brand;
  final String price;
  final String imagePath; // We'll use a placeholder URL or asset for now
  final String distance;
  final String fuel;
  final String transmission; // 'Diesel', 'Electric'
  final bool isElectric;
  final String acceleration; // '0-100km/10s'
  final String tempControl; // 'Cool'

  Car({
    required this.name,
    required this.brand,
    required this.price,
    required this.imagePath,
    required this.distance,
    required this.fuel,
    this.transmission = 'Automatic',
    this.isElectric = false,
    this.acceleration = '0-100km/8s',
    this.tempControl = 'Temp Ctrl',
  });
}

final List<Car> dummyCars = [
  Car(
    name: 'Fortuner GR',
    brand: 'Toyota',
    price: '\$45.00',
    imagePath: 'assets/fortuner.png', // Placeholder
    distance: '> 870km',
    fuel: '50L',
    transmission: 'Diesel',
    acceleration: '0-100km/11s',
  ),
  Car(
    name: 'Corolla Cross',
    brand: 'Toyota',
    price: '\$30.00',
    imagePath: 'assets/corolla.png',
    distance: '> 4km',
    fuel: '50L',
    transmission: 'Petrol',
  ),
  Car(
    name: 'Ionic 5',
    brand: 'Hyundai',
    price: '\$55.00',
    imagePath: 'assets/ionic5.png',
    distance: '> 8km',
    fuel: '80%',
    isElectric: true,
    transmission: 'Electric',
  ),
];
