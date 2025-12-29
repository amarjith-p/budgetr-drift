import 'package:flutter/material.dart';

class IconMetadata {
  final IconData icon;
  final List<String> tags;
  const IconMetadata(this.icon, this.tags);
}

class IconGroup {
  final String title;
  final List<IconMetadata> icons;
  const IconGroup(this.title, this.icons);
}

class IconConstants {
  // Helper to safely retrieve icon for tree-shaking compatibility
  static IconData getIconByCode(int code) {
    try {
      for (var group in iconGroups) {
        for (var meta in group.icons) {
          if (meta.icon.codePoint == code) {
            return meta.icon;
          }
        }
      }
      // Fallback for icons that might have been saved but removed from list
      // Note: This relies on the font family being loaded
      return IconData(code, fontFamily: 'MaterialIcons');
    } catch (_) {
      return Icons.category_outlined;
    }
  }

  static const List<IconGroup> iconGroups = [
    IconGroup('General & Finance', [
      IconMetadata(Icons.currency_rupee, [
        'rupee',
        'inr',
        'money',
        'cash',
        'indian',
        'paisa',
        'amount',
      ]),
      IconMetadata(Icons.account_balance_wallet, [
        'wallet',
        'purse',
        'pocket',
        'money',
        'cash',
        'balance',
      ]),
      IconMetadata(Icons.attach_money, [
        'salary',
        'income',
        'bonus',
        'profit',
        'wage',
        'earnings',
      ]),
      IconMetadata(Icons.credit_card, [
        'card',
        'debit',
        'credit',
        'atm',
        'visa',
        'mastercard',
        'payment',
      ]),
      IconMetadata(Icons.qr_code_scanner, [
        'upi',
        'scan',
        'paytm',
        'gpay',
        'phonepe',
        'bhim',
        'online',
      ]),
      IconMetadata(Icons.savings, [
        'piggy',
        'bank',
        'save',
        'invest',
        'fd',
        'rd',
        'mutual fund',
        'gold',
      ]),
      IconMetadata(Icons.receipt_long, [
        'bill',
        'invoice',
        'tax',
        'receipt',
        'challan',
        'paper',
      ]),
      IconMetadata(Icons.calculate, ['math', 'calc', 'budget', 'hisab']),
      IconMetadata(Icons.account_balance, [
        'bank',
        'loan',
        'emi',
        'branch',
        'sbi',
        'hdfc',
      ]),
      IconMetadata(Icons.currency_exchange, [
        'exchange',
        'swap',
        'transfer',
        'remittance',
        'forex',
      ]),
      IconMetadata(Icons.diamond, [
        'luxury',
        'gem',
        'jewelry',
        'gold',
        'expensive',
        'wedding',
        'shadi',
      ]),
      IconMetadata(Icons.shopping_bag, [
        'shop',
        'buy',
        'store',
        'mall',
        'fashion',
        'kapde',
        'clothes',
      ]),
      IconMetadata(Icons.card_giftcard, [
        'gift',
        'present',
        'shagun',
        'lifafa',
        'reward',
        'bonus',
        'rakhi',
      ]),
      IconMetadata(Icons.redeem, ['coupon', 'voucher', 'discount', 'offer']),
      IconMetadata(Icons.category, ['general', 'other', 'misc', 'box']),
      IconMetadata(Icons.currency_bitcoin, [
        'crypto',
        'bitcoin',
        'digital',
        'coin',
      ]),
      IconMetadata(Icons.payments, ['cash', 'pay', 'transaction']),
      IconMetadata(Icons.request_quote, ['bill', 'invoice', 'estimate']),
    ]),

    IconGroup('Food & Drink', [
      IconMetadata(Icons.restaurant, [
        'food',
        'dinner',
        'lunch',
        'eat',
        'hotel',
        'dhaba',
        'meal',
      ]),
      IconMetadata(Icons.local_cafe, [
        'chai',
        'tea',
        'coffee',
        'cafe',
        'break',
        'morning',
        'beverage',
      ]),
      IconMetadata(Icons.fastfood, [
        'snack',
        'burger',
        'samosa',
        'chaat',
        'street food',
        'junk',
      ]),
      IconMetadata(Icons.local_pizza, [
        'pizza',
        'italian',
        'dominos',
        'cheese',
      ]),
      IconMetadata(Icons.lunch_dining, ['tiffin', 'dabba', 'lunch', 'meal']),
      IconMetadata(Icons.restaurant_menu, [
        'menu',
        'zomato',
        'swiggy',
        'delivery',
        'order',
      ]),
      IconMetadata(Icons.local_bar, [
        'alcohol',
        'wine',
        'beer',
        'drink',
        'party',
        'club',
        'pub',
      ]),
      IconMetadata(Icons.icecream, [
        'dessert',
        'sweet',
        'mithai',
        'summer',
        'kulfi',
      ]),
      IconMetadata(Icons.cake, [
        'birthday',
        'party',
        'celebration',
        'anniversary',
      ]),
      IconMetadata(Icons.kitchen, ['cook', 'grocery', 'ration', 'ingredients']),
      IconMetadata(Icons.local_grocery_store, [
        'grocery',
        'kirana',
        'supermarket',
        'mart',
        'bigbasket',
      ]),
      IconMetadata(Icons.egg, [
        'breakfast',
        'eggs',
        'anda',
        'nonveg',
        'protein',
      ]),
      IconMetadata(Icons.emoji_food_beverage, [
        'juice',
        'lassi',
        'shake',
        'drinks',
      ]),
      IconMetadata(Icons.rice_bowl, [
        'rice',
        'chawal',
        'biryani',
        'meal',
        'thali',
      ]),
      IconMetadata(Icons.delivery_dining, ['delivery', 'food', 'scooter']),
      IconMetadata(Icons.bakery_dining, ['bread', 'bun', 'toast', 'bakery']),
    ]),

    IconGroup('Travel & Transport', [
      IconMetadata(Icons.local_taxi, [
        'auto',
        'rickshaw',
        'cab',
        'ola',
        'uber',
        'taxi',
        'ride',
      ]),
      IconMetadata(Icons.two_wheeler, [
        'bike',
        'scooter',
        'scooty',
        'activa',
        'motorcycle',
      ]),
      IconMetadata(Icons.directions_car, [
        'car',
        'fuel',
        'petrol',
        'diesel',
        'drive',
        'maintenance',
      ]),
      IconMetadata(Icons.local_gas_station, [
        'fuel',
        'petrol',
        'diesel',
        'cng',
        'pump',
        'gas',
      ]),
      IconMetadata(Icons.train, [
        'train',
        'rail',
        'irctc',
        'metro',
        'subway',
        'ticket',
        'station',
      ]),
      IconMetadata(Icons.directions_bus, [
        'bus',
        'public',
        'transport',
        'ticket',
      ]),
      IconMetadata(Icons.flight, [
        'flight',
        'plane',
        'air',
        'travel',
        'trip',
        'ticket',
        'airport',
      ]),
      IconMetadata(Icons.commute, ['office', 'daily', 'updown']),
      IconMetadata(Icons.map, ['gps', 'navigation', 'trip', 'tour']),
      IconMetadata(Icons.car_rental, ['rent', 'hire', 'cab']),
      IconMetadata(Icons.local_parking_rounded, ['parking', 'lot', 'garage']),
      IconMetadata(Icons.no_crash, [
        'insurance',
        'accident',
        'repair',
        'service',
      ]),
      IconMetadata(Icons.toll, ['toll', 'fastag', 'highway', 'tax']),
      IconMetadata(Icons.subway, ['metro', 'underground']),
      IconMetadata(Icons.airline_seat_recline_extra, [
        'seat',
        'travel',
        'comfort',
      ]),
    ]),

    IconGroup('Home & Utilities', [
      IconMetadata(Icons.home, ['house', 'rent', 'emi', 'home', 'ghar']),
      IconMetadata(Icons.lightbulb, [
        'electricity',
        'bijli',
        'power',
        'bill',
        'current',
      ]),
      IconMetadata(Icons.water_drop, ['water', 'paani', 'tanker', 'bill']),
      IconMetadata(Icons.wifi, [
        'internet',
        'broadband',
        'connection',
        'jio',
        'airtel',
      ]),
      IconMetadata(Icons.smartphone, [
        'mobile',
        'recharge',
        'phone',
        'bill',
        'topup',
      ]),
      IconMetadata(Icons.propane_tank, ['gas', 'cylinder', 'lpg', 'cooking']),
      IconMetadata(Icons.tv, [
        'television',
        'dth',
        'cable',
        'netflix',
        'prime',
        'subscription',
      ]),
      IconMetadata(Icons.cleaning_services, [
        'maid',
        'cleaner',
        'helper',
        'cleaning',
        'housekeeping',
      ]),
      IconMetadata(Icons.local_laundry_service, [
        'laundry',
        'dhobi',
        'iron',
        'wash',
      ]),
      IconMetadata(Icons.bed, ['furniture', 'decor', 'interior']),
      IconMetadata(Icons.plumbing, ['repair', 'plumber', 'maintenance']),
      IconMetadata(Icons.electrical_services, [
        'electrician',
        'repair',
        'wiring',
      ]),
      IconMetadata(Icons.pets, ['dog', 'cat', 'pet', 'food', 'vet']),
      IconMetadata(Icons.child_care, ['kids', 'baby', 'diaper', 'nanny']),
      IconMetadata(Icons.satellite_alt, ['dth', 'dish', 'tv']),
      IconMetadata(Icons.sim_card, ['sim', 'mobile', 'prepaid', 'postpaid']),
      IconMetadata(Icons.pest_control, ['pest', 'insects', 'spray']),
      IconMetadata(Icons.solar_power, ['solar', 'energy', 'green']),
    ]),

    IconGroup('Health & Personal', [
      IconMetadata(Icons.medical_services, [
        'doctor',
        'hospital',
        'clinic',
        'checkup',
        'fee',
      ]),
      IconMetadata(Icons.medication, [
        'medicine',
        'pharmacy',
        'chemist',
        'tablets',
        'drugs',
        'davai',
      ]),
      IconMetadata(Icons.monitor_heart, ['health', 'insurance', 'life']),
      IconMetadata(Icons.fitness_center, [
        'gym',
        'workout',
        'yoga',
        'fit',
        'membership',
      ]),
      IconMetadata(Icons.spa, [
        'salon',
        'haircut',
        'beauty',
        'makeup',
        'massage',
        'barber',
      ]),
      IconMetadata(Icons.checkroom, [
        'clothes',
        'fashion',
        'dress',
        'shopping',
        'wardrobe',
      ]),
      IconMetadata(Icons.watch, ['accessories', 'watch', 'jewelry']),
      IconMetadata(Icons.content_cut, ['hair', 'salon', 'barber']),
      IconMetadata(Icons.face_retouching_natural, [
        'makeup',
        'beauty',
        'cosmetics',
      ]),
      IconMetadata(Icons.self_improvement, ['yoga', 'meditation', 'peace']),
    ]),

    IconGroup('Education & Work', [
      IconMetadata(Icons.school, [
        'school',
        'college',
        'fees',
        'education',
        'kids',
      ]),
      IconMetadata(Icons.menu_book, ['books', 'stationery', 'copy', 'read']),
      IconMetadata(Icons.cast_for_education, [
        'tuition',
        'coaching',
        'course',
        'learning',
      ]),
      IconMetadata(Icons.work, ['office', 'business', 'job']),
      IconMetadata(Icons.computer, ['laptop', 'pc', 'repair', 'software']),
      IconMetadata(Icons.print, ['xerox', 'print', 'documents']),
      IconMetadata(Icons.design_services, ['design', 'creative', 'art']),
      IconMetadata(Icons.engineering, ['engineer', 'work', 'technical']),
      IconMetadata(Icons.psychology, ['learning', 'brain', 'skill']),
    ]),

    IconGroup('Entertainment', [
      IconMetadata(Icons.movie, [
        'movie',
        'cinema',
        'film',
        'theater',
        'pvr',
        'tickets',
      ]),
      IconMetadata(Icons.live_tv, ['ott', 'subscription', 'hotstar', 'series']),
      IconMetadata(Icons.music_note, ['music', 'spotify', 'concert']),
      IconMetadata(Icons.sports_cricket, [
        'cricket',
        'ipl',
        'match',
        'sports',
        'bat',
      ]),
      IconMetadata(Icons.sports_esports, ['game', 'gaming', 'playstation']),
      IconMetadata(Icons.deck, [
        'holiday',
        'vacation',
        'resort',
        'picnic',
        'weekend',
      ]),
      IconMetadata(Icons.camera_alt, ['photo', 'camera', 'shoot']),
      IconMetadata(Icons.sports_soccer, ['football', 'sports']),
      IconMetadata(Icons.pool, ['swim', 'water', 'sport']),
      IconMetadata(Icons.theater_comedy, ['comedy', 'show', 'event']),
    ]),

    IconGroup('Miscellaneous', [
      IconMetadata(Icons.temple_hindu, [
        'puja',
        'temple',
        'mandir',
        'religious',
        'donation',
      ]),
      IconMetadata(Icons.mosque, ['mosque', 'religious', 'donation']),
      IconMetadata(Icons.church, ['church', 'religious', 'donation']),
      IconMetadata(Icons.favorite, ['charity', 'donation', 'help']),
      IconMetadata(Icons.celebration, [
        'festival',
        'diwali',
        'eid',
        'christmas',
        'party',
      ]),
      IconMetadata(Icons.build, ['repair', 'service', 'maintenance']),
      IconMetadata(Icons.lock, ['security', 'guard']),
      IconMetadata(Icons.local_shipping, ['courier', 'delivery', 'post']),
      IconMetadata(Icons.gavel, ['legal', 'lawyer', 'challan', 'fine']),
      IconMetadata(Icons.cloud, ['cloud', 'subscription', 'drive']),
      IconMetadata(Icons.search, ['search', 'find']),
      IconMetadata(Icons.notifications, ['alert']),
      IconMetadata(Icons.volunteer_activism, ['donate', 'give', 'help']),
      IconMetadata(Icons.pets, ['animal', 'pet', 'vet']),
    ]),
  ];

  // Flattened list for the search logic to iterate easily
  static List<IconMetadata> get allIcons =>
      iconGroups.expand((group) => group.icons).toList();
}
