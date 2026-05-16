import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../models/listing_model.dart';
import 'promote_payment_screen.dart'; // We will create this next

class AddListingFlow extends StatefulWidget {
  const AddListingFlow({super.key});

  @override
  State<AddListingFlow> createState() => _AddListingFlowState();
}

class _AddListingFlowState extends State<AddListingFlow> {
  final PageController _pageController = PageController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  int _currentStep = 0;
  final int _totalSteps = 6;

  ListingModel _draftListing = ListingModel();

  bool _validateCurrentStep() {
    if (_formKey.currentState != null && !_formKey.currentState!.validate()) {
      return false; 
    }
    if (_currentStep == 0 && _draftListing.propertyType == null) {
      _showErrorSnackbar("Please select a property type to continue.");
      return false;
    } else if (_currentStep == 4 && (_draftListing.city == null || _draftListing.streetAddress == null)) {
      _showErrorSnackbar("Please provide a complete address and city.");
      return false;
    }
    return true;
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.redAccent));
  }

  void _nextPage() {
    if (_validateCurrentStep()) {
      if (_currentStep < _totalSteps - 1) {
        setState(() => _currentStep++);
        _pageController.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeInOutCubic);
      } else {
        _submitListing();
      }
    }
  }

  void _prevPage() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(duration: const Duration(milliseconds: 350), curve: Curves.easeInOutCubic);
    } else {
      Navigator.pop(context);
    }
  }

  void _submitListing() {
    // If user chose to promote, send them to the payment screen
    if (_draftListing.isPromoted) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => PromotePaymentScreen(listing: _draftListing)),
      );
    } else {
      // Otherwise, just publish normally
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Listing published successfully!"), backgroundColor: Colors.green),
      );
      Navigator.pop(context); // Close flow
    }
  }

  @override
  Widget build(BuildContext context) {
    double progress = (_currentStep + 1) / _totalSteps;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: _prevPage),
        title: const Text("List a Property", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Center(child: Padding(padding: const EdgeInsets.only(right: 16.0), child: Text("Step ${(_currentStep + 1)} of $_totalSteps", style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)))),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(value: progress, backgroundColor: Colors.grey[100], color: primaryOrange, minHeight: 4),
        ),
      ),
      body: Form(
        key: _formKey,
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(), 
          children: [
            _TypeSelectionStep(selectedType: _draftListing.propertyType, onSelected: (type) => setState(() => _draftListing.propertyType = type)),
            _PropertyDetailsStep(listing: _draftListing, onChanged: (updated) => setState(() => _draftListing = updated)),
            _PricingStep(listing: _draftListing, onChanged: (updated) => setState(() => _draftListing = updated)),
            _PhysicalDetailsStep(listing: _draftListing, onChanged: (updated) => setState(() => _draftListing = updated)),
            _LocationStep(listing: _draftListing, onChanged: (updated) => setState(() => _draftListing = updated)),
            _ReviewPublishStep(listing: _draftListing, onChanged: (updated) => setState(() => _draftListing = updated)),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _prevPage,
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), side: BorderSide(color: Colors.grey[300]!), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text("Back", style: TextStyle(color: Colors.black)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(backgroundColor: primaryOrange, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: Text(_currentStep == _totalSteps - 1 ? "Submit Listing" : "Next", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --------------------------------------------------------------------------
// MODULAR STEPS (Place these at the bottom of the same file)
// --------------------------------------------------------------------------

class _TypeSelectionStep extends StatelessWidget {
  final PropertyType? selectedType;
  final ValueChanged<PropertyType> onSelected;
  const _TypeSelectionStep({required this.selectedType, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Choose Property Type", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text("What type of property are you listing?", style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 32),
          ...PropertyType.values.map((type) {
            final isSelected = selectedType == type;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: InkWell(
                onTap: () => onSelected(type),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(border: Border.all(color: isSelected ? primaryOrange : Colors.grey[200]!, width: isSelected ? 2 : 1), borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    children: [
                      Icon(type == PropertyType.apartment ? Icons.apartment : type == PropertyType.house ? Icons.home_outlined : type == PropertyType.land ? Icons.landscape : Icons.store_mall_directory_outlined, color: isSelected ? primaryOrange : Colors.grey[600]),
                      const SizedBox(width: 16),
                      Text(type.toString().split('.').last.toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? primaryOrange : Colors.black87)),
                      const Spacer(),
                      Radio<PropertyType>(value: type, groupValue: selectedType, activeColor: primaryOrange, onChanged: (val) { if (val != null) onSelected(val); })
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _PropertyDetailsStep extends StatelessWidget {
  final ListingModel listing;
  final ValueChanged<ListingModel> onChanged;
  const _PropertyDetailsStep({required this.listing, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Property Details", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text("Add title and description & Upload high-quality images.", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          const SizedBox(height: 24),
          
          const Text("Property Title", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: listing.title,
            onChanged: (val) => onChanged(listing.copyWith(title: val)),
            decoration: customInputDecoration("e.g. Modern 2-Bed Apartment"),
            validator: (value) => (value == null || value.trim().isEmpty) ? 'Required' : null,
          ),
          
          const SizedBox(height: 24),
          const Text("Description", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: listing.description,
            maxLines: 4,
            onChanged: (val) => onChanged(listing.copyWith(description: val)),
            decoration: customInputDecoration("Describe your property..."),
          ),

          const SizedBox(height: 32),
          // ADD PHOTOS & VIDEOS SECTION
          InkWell(
            onTap: () {
              // TODO: Implement ImagePicker here. For now, mocking an image addition.
              final updatedImages = List<String>.from(listing.imagePaths)..add("mock_image_${DateTime.now().millisecondsSinceEpoch}.jpg");
              onChanged(listing.copyWith(imagePaths: updatedImages));
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primaryOrange.withOpacity(0.5), width: 1.5, style: BorderStyle.solid), // Dashed effect typically needs dotted_border package, solid used for zero-dependency
              ),
              child: Column(
                children: [
                  const Icon(Icons.camera_alt_outlined, color: primaryOrange, size: 36),
                  const SizedBox(height: 8),
                  Text("Tap to upload photos & videos", style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ),
          ),
          
          // Show thumbnails if images exist
          if (listing.imagePaths.isNotEmpty) ...[
            const SizedBox(height: 16),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: listing.imagePaths.length,
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(right: 12),
                        width: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.image, color: Colors.grey), // Placeholder for actual Image.file
                      ),
                      Positioned(
                        top: -4,
                        right: 4,
                        child: IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.redAccent, size: 20),
                          onPressed: () {
                            final updatedImages = List<String>.from(listing.imagePaths)..removeAt(index);
                            onChanged(listing.copyWith(imagePaths: updatedImages));
                          },
                        ),
                      )
                    ],
                  );
                },
              ),
            )
          ]
        ],
      ),
    );
  }
}

class _PricingStep extends StatelessWidget {
  final ListingModel listing;
  final ValueChanged<ListingModel> onChanged;
  const _PricingStep({required this.listing, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Set Pricing", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: ChoiceChip(label: const Center(child: Text("For Rent")), selected: listing.listingType == ListingType.forRent, onSelected: (val) { if (val) onChanged(listing.copyWith(listingType: ListingType.forRent)); })),
              const SizedBox(width: 12),
              Expanded(child: ChoiceChip(label: const Center(child: Text("For Sale")), selected: listing.listingType == ListingType.forSale, onSelected: (val) { if (val) onChanged(listing.copyWith(listingType: ListingType.forSale)); })),
            ],
          ),
          const SizedBox(height: 32),
          Text(listing.listingType == ListingType.forRent ? "Monthly rent CFA" : "Price CFA", style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: listing.price?.toString() ?? '',
            keyboardType: TextInputType.number,
            onChanged: (val) => onChanged(listing.copyWith(price: double.tryParse(val))),
            decoration: customInputDecoration("Enter amount"),
          ),
          const SizedBox(height: 24),
          const Text("Finder's Fee CFA", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: listing.findersFee?.toString() ?? '',
            keyboardType: TextInputType.number,
            onChanged: (val) => onChanged(listing.copyWith(findersFee: double.tryParse(val))),
            decoration: customInputDecoration("Enter finder's fee"),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Text("Fixed Price", style: TextStyle(fontWeight: FontWeight.bold)),
              Radio(value: false, groupValue: listing.isNegotiable, activeColor: primaryOrange, onChanged: (val) => onChanged(listing.copyWith(isNegotiable: val as bool))),
              const SizedBox(width: 16),
              const Text("Negotiable", style: TextStyle(fontWeight: FontWeight.bold)),
              Radio(value: true, groupValue: listing.isNegotiable, activeColor: primaryOrange, onChanged: (val) => onChanged(listing.copyWith(isNegotiable: val as bool))),
            ],
          )
        ],
      ),
    );
  }
}

class _PhysicalDetailsStep extends StatelessWidget {
  final ListingModel listing;
  final ValueChanged<ListingModel> onChanged;
  const _PhysicalDetailsStep({required this.listing, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Space details implemented in previous milestone"));
  }
}

// --- NEW: STEP 5 (LOCATION) ---
class _LocationStep extends StatelessWidget {
  final ListingModel listing;
  final ValueChanged<ListingModel> onChanged;
  const _LocationStep({required this.listing, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Add location", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text("Where is your property located?", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          const SizedBox(height: 24),
          
          const Text("Street Address", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: listing.streetAddress,
            onChanged: (val) => onChanged(listing.copyWith(streetAddress: val)),
            decoration: customInputDecoration("Enter full address"),
            validator: (value) => (value == null || value.trim().isEmpty) ? 'Required' : null,
          ),
          
          const SizedBox(height: 24),
          const Text("City", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: listing.city,
            items: ["Douala", "Yaoundé", "Bamenda", "Bafoussam"].map((city) {
              return DropdownMenuItem(value: city, child: Text(city));
            }).toList(),
            onChanged: (val) => onChanged(listing.copyWith(city: val)),
            decoration: customInputDecoration("Select City"),
            validator: (value) => value == null ? 'Please select a city' : null,
          ),

          const SizedBox(height: 32),
          const Text("Location", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          // Map Placeholder
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
              image: const DecorationImage(
                image: NetworkImage("https://www.mapquestapi.com/staticmap/v5/map?key=YOUR_KEY&center=Douala&zoom=12&size=400,200"), // Fallback if no local asset
                fit: BoxFit.cover,
              ),
            ),
            child: const Center(child: Icon(Icons.location_on, color: Colors.red, size: 48)),
          )
        ],
      ),
    );
  }
}

// --- NEW: STEP 6 (REVIEW & PUBLISH) ---
class _ReviewPublishStep extends StatelessWidget {
  final ListingModel listing;
  final ValueChanged<ListingModel> onChanged;
  const _ReviewPublishStep({required this.listing, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Publish Listing", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text("Review and publish your property", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          const SizedBox(height: 24),
          
          // Promote Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryOrange.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: primaryOrange.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.stars, color: primaryOrange),
                    const SizedBox(width: 8),
                    const Text("Promote listing", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 8),
                Text("Get 5x more views and priority placement in search results", style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Promote this listing - 5,000\nCFA/10 Days", style: TextStyle(color: primaryOrange, fontWeight: FontWeight.bold, fontSize: 13)),
                    Switch(
                      value: listing.isPromoted,
                      activeColor: primaryOrange,
                      onChanged: (val) => onChanged(listing.copyWith(isPromoted: val)),
                    )
                  ],
                )
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          const Text("Listing Summary", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 16),
          _buildSummaryRow("Property Type:", listing.propertyType?.name.toUpperCase() ?? ""),
          _buildSummaryRow("Title:", listing.title),
          _buildSummaryRow("Price:", "${listing.price ?? 0} CFA"),
          _buildSummaryRow("Finder's Fee:", "${listing.findersFee ?? 0} CFA"),
          _buildSummaryRow("City:", listing.city ?? ""),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}