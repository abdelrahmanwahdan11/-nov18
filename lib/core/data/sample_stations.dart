import '../models/station.dart';

List<Station> buildSampleStations() {
  final images = [
    'https://images.unsplash.com/photo-1503376780353-7e6692767b70?auto=format&fit=crop&w=800&q=60',
    'https://images.unsplash.com/photo-1489515217757-5fd1be406fef?auto=format&fit=crop&w=900&q=60',
    'https://images.unsplash.com/photo-1502877338535-766e1452684a?auto=format&fit=crop&w=900&q=60',
  ];
  return List.generate(12, (index) {
    return Station(
      id: 'station-$index',
      name: 'Green Hub ${index + 1}',
      city: index.isEven ? 'Munich' : 'Abu Dhabi',
      country: index.isEven ? 'Germany' : 'UAE',
      price: 0.25 + index * 0.02,
      availability: index % 3 == 0 ? 'Now' : '24/7',
      image: images[index % images.length],
    );
  });
}
