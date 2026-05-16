enum PropertyType { apartment, house, land, commercial }
enum ListingType { forRent, forSale }

class ListingModel {
  PropertyType? propertyType;
  String title;
  String description;
  List<String> imagePaths; 
  ListingType listingType;
  double? price;
  double? findersFee;
  bool isNegotiable;
  
  // Physical features
  int bedrooms;
  int bathrooms;
  double? sizeSqM;
  String? spaceType;
  List<String> features;

  // Location (New)
  String? streetAddress;
  String? city;

  // Promotion (New)
  bool isPromoted;

  ListingModel({
    this.propertyType,
    this.title = '',
    this.description = '',
    List<String>? imagePaths,
    this.listingType = ListingType.forRent,
    this.price,
    this.findersFee,
    this.isNegotiable = true,
    this.bedrooms = 0,
    this.bathrooms = 0,
    this.sizeSqM,
    this.spaceType,
    List<String>? features,
    this.streetAddress,
    this.city,
    this.isPromoted = false,
  })  : imagePaths = imagePaths ?? [],
        features = features ?? [];

  ListingModel copyWith({
    PropertyType? propertyType,
    String? title,
    String? description,
    List<String>? imagePaths,
    ListingType? listingType,
    double? price,
    double? findersFee,
    bool? isNegotiable,
    int? bedrooms,
    int? bathrooms,
    double? sizeSqM,
    String? spaceType,
    List<String>? features,
    String? streetAddress,
    String? city,
    bool? isPromoted,
  }) {
    return ListingModel(
      propertyType: propertyType ?? this.propertyType,
      title: title ?? this.title,
      description: description ?? this.description,
      imagePaths: imagePaths ?? this.imagePaths,
      listingType: listingType ?? this.listingType,
      price: price ?? this.price,
      findersFee: findersFee ?? this.findersFee,
      isNegotiable: isNegotiable ?? this.isNegotiable,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      sizeSqM: sizeSqM ?? this.sizeSqM,
      spaceType: spaceType ?? this.spaceType,
      features: features ?? this.features,
      streetAddress: streetAddress ?? this.streetAddress,
      city: city ?? this.city,
      isPromoted: isPromoted ?? this.isPromoted,
    );
  }
}