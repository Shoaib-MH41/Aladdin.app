import 'package:flutter/material.dart';

class AdsScreen extends StatelessWidget {
  final String projectName;
  final double initialBudget;
  final String initialAdText;

  const AdsScreen({
    Key? key,
    required this.projectName,
    this.initialBudget = 100.0,
    this.initialAdText = "میرے ایپ کو آزمائیں!",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    TextEditingController budgetController = TextEditingController(text: initialBudget.toString());
    TextEditingController adTextController = TextEditingController(text: initialAdText);

    return Scaffold(
      appBar: AppBar(
        title: Text('اشتہار مہم - $projectName'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📢 نئی اشتہار مہم بنائیں',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'اپنی ایپ کی مارکیٹنگ کے لیے اشتہار مہم شروع کریں',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'اشتہار مہم کا نام',
                hintText: 'مثال: ${projectName} لانچ مہم',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.campaign),
              ),
            ),
            SizedBox(height: 15),
            TextFormField(
              controller: budgetController,
              decoration: InputDecoration(
                labelText: 'روزانہ بجٹ (\$)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
                suffixText: 'USD',
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            Slider(
              value: double.tryParse(budgetController.text) ?? initialBudget,
              min: 10,
              max: 1000,
              divisions: 99,
              label: '\$${budgetController.text}',
              onChanged: (value) {
                budgetController.text = value.toStringAsFixed(2);
              },
            ),
            SizedBox(height: 15),
            TextFormField(
              controller: adTextController,
              decoration: InputDecoration(
                labelText: 'اشتہاری متن',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.text_fields),
              ),
              maxLines: 4,
            ),
            SizedBox(height: 10),
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'اشتہار کا نمونہ:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Text(
                        adTextController.text,
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 25),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context, {
                        'name': nameController.text,
                        'budget': double.tryParse(budgetController.text) ?? initialBudget,
                        'adText': adTextController.text,
                      });
                    },
                    icon: Icon(Icons.rocket_launch),
                    label: Text('اشتہار مہم شروع کریں'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            Text(
              '💡 مشورہ: چھوٹی رقم سے شروع کریں اور کارکردگی دیکھ کر بجٹ بڑھائیں',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
