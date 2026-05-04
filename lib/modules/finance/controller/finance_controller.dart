import 'dart:math';
import 'package:get/get.dart';
import 'package:agremate_admin/modules/finance/model/finance_model.dart';

class FinanceController extends GetxController {
  final rentPayments = <RentPaymentModel>[].obs;
  final revenueRecords = <RevenueRecord>[].obs;
  final totalRevenue = 0.0.obs;
  final isLoading = true.obs;
  final selectedPropertyPayments = <RentPaymentModel>[].obs;
  final selectedPropertyName = ''.obs;
  final _rng = Random(42);

  List<Map<String, dynamic>> get rentedProperties {
    final map = <String, Map<String, dynamic>>{};
    for (final p in rentPayments) {
      if (!map.containsKey(p.propertyId)) {
        map[p.propertyId] = {
          'propertyId': p.propertyId,
          'propertyName': p.propertyName,
          'landlordName': p.landlordName,
          'tenantName': p.tenantName,
          'totalPaid': 0.0,
        };
      }
      map[p.propertyId]!['totalPaid'] = (map[p.propertyId]!['totalPaid'] as double) + p.amount;
    }
    return map.values.toList();
  }

  List<RentPaymentModel> get currentPayments => 
      selectedPropertyName.value.isEmpty ? rentPayments.toList() : selectedPropertyPayments.toList();

  double get currentTotalRevenue {
    double total = 0;
    for (final p in currentPayments) {
      if (p.status == 'paid') total += p.amount;
    }
    return total;
  }

  int get currentRentedPropertiesCount {
    if (selectedPropertyName.value.isNotEmpty) return 1;
    return rentedProperties.length;
  }

  int get currentPaidCount => currentPayments.where((p) => p.status == 'paid').length;
  int get currentOverdueCount => currentPayments.where((p) => p.status == 'overdue').length;

  List<RevenueRecord> get currentRevenueRecords {
    if (selectedPropertyName.value.isEmpty) return revenueRecords.toList();
    
    // Compute for selected property
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final records = <RevenueRecord>[];
    for (int m=0; m<12; m++) {
      double mt = 0;
      for (final p in currentPayments.where((p) => p.month == months[m] && p.status == 'paid')) {
        mt += p.amount;
      }
      records.add(RevenueRecord(month: months[m], amount: mt, year: 2025));
    }
    return records;
  }

  @override
  void onInit() {
    super.onInit();
    _generateData();
  }

  void _generateData() {
    isLoading.value = true;
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final props = [
      {'id':'P1','name':'Andheri Apt 1','ll':'Rajesh Sharma','tn':'Aarav Menon'},
      {'id':'P3','name':'Powai Studio 5','ll':'Amit Kumar','tn':'Rohan Pillai'},
      {'id':'P5','name':'Bandra Villa 3','ll':'Priya Patel','tn':'Ishika Sen'},
      {'id':'P7','name':'Juhu Penthouse','ll':'Sunita Gupta','tn':'Diya Chopra'},
      {'id':'P9','name':'Malad Duplex 4','ll':'Vikram Singh','tn':'Arjun Saxena'},
      {'id':'P11','name':'Goregaon Apt 7','ll':'Neha Verma','tn':'Meera Kulkarni'},
      {'id':'P13','name':'Thane Commercial','ll':'Rahul Joshi','tn':'Varun Bansal'},
      {'id':'P15','name':'Worli Studio 8','ll':'Anita Desai','tn':'Nisha Pandey'},
      {'id':'P17','name':'Dadar Apt 12','ll':'Suresh Reddy','tn':'Siddharth Jain'},
      {'id':'P19','name':'Kurla Villa 6','ll':'Kavita Nair','tn':'Tanya Malhotra'},
    ];
    final sts = ['paid','paid','paid','pending','overdue'];
    final payments = <RentPaymentModel>[];
    double total = 0;
    for (final p in props) {
      final rent = (_rng.nextDouble()*60+15)*1000;
      for (int m=0;m<12;m++) {
        final amt = rent+_rng.nextInt(5000).toDouble();
        final st = sts[_rng.nextInt(sts.length)];
        final dueDate = DateTime(2025, m + 1, 5);
        payments.add(RentPaymentModel(
          id:'RP${payments.length+1}',propertyId:p['id']!,propertyName:p['name']!,
          landlordId:'L${props.indexOf(p)+1}',landlordName:p['ll']!,
          tenantId:'T${props.indexOf(p)+1}',tenantName:p['tn']!,
          amount:amt,month:months[m],year:2025,status:st,
          dueDate: dueDate,
          paidDate:st=='paid'?DateTime(2025,m+1,_rng.nextInt(28)+1):null,
          transactionId:st=='paid' ? 'TXN${_rng.nextInt(900000) + 100000}' : null,
        ));
        if(st=='paid') total+=amt;
      }
    }
    rentPayments.value = payments;
    totalRevenue.value = total;
    final records = <RevenueRecord>[];
    for (int m=0;m<12;m++) {
      double mt=0;
      for(final p in payments.where((p)=>p.month==months[m]&&p.status=='paid')) { mt+=p.amount; }
      records.add(RevenueRecord(month:months[m],amount:mt,year:2025));
    }
    revenueRecords.value = records;
    isLoading.value = false;
  }

  void selectProperty(String propertyId, String propertyName) {
    selectedPropertyName.value = propertyName;
    selectedPropertyPayments.value = rentPayments.where((p)=>p.propertyId==propertyId).toList();
  }

  void clearSelection() {
    selectedPropertyName.value = '';
    selectedPropertyPayments.value = [];
  }
}
