import 'dart:ffi';

import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import '../../../constance/loadingIndicator.dart';
import '../../../constance/toastMessages.dart';
import '../../../models/SavingMember.dart';
import '../../../services/saving_members_service.dart';
import '../../../services/saving_transactions_service.dart';
import '../../login/logout.dart';
import 'print_slip.dart';

class SavingsHome extends StatefulWidget {
  const SavingsHome({super.key});

  @override
  State<SavingsHome> createState() => _SavingsHomeState();
}

class _SavingsHomeState extends State<SavingsHome> {
  final storage = new FlutterSecureStorage();
  String _userName = "";
  String? savingBalance;

  List<SavingMember>? savingMembers;

  GlobalKey<AutoCompleteTextFieldState<SavingMember>> keyMember =
      new GlobalKey();
  AutoCompleteTextField<SavingMember>? textFieldMember;
  SavingMember? selectedMember;
  TextEditingController textEditingControllerMember =
      new TextEditingController();

  final _formKey = GlobalKey<FormBuilderState>();

  final databaseReference = FirebaseFirestore.instance;

  getMemberTransaction() {
    SavingTransactionsService.readTransactionOfMember(selectedMember?.id)
        .then((value) {
      double total = 0;
      //calculate balance
      value.forEach((element) {
        if (element.status == "debit")
          total -= double.parse(element.amount);
        else
          total += double.parse(element.amount);
      });

      setState(() {
        savingBalance = total.toStringAsFixed(2);
      });
    });
  }

  @override
  initState() {
    super.initState();

    storage.read(key: "username").then((value) {
      setState(() {
        _userName = value!;
      });
    });

    SavingMembersServices.readMembers().then((value) {
      setState(() {
        savingMembers = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var welcomeText = Text("Hi $_userName,",
        style: TextStyle(
            fontSize: 24.0,
            letterSpacing: 1.5,
            fontWeight: FontWeight.bold,
            color: Colors.white));

    var memberNumbersField = savingMembers == null
        ? CircularProgressIndicator()
        : FormBuilderField(
            name: "memberId",
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(),
            ]),
            builder: (field) {
              return AutoCompleteTextField<SavingMember>(
                decoration: InputDecoration(
                  labelText: "Member Number",
                  hintText: "Member Number",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5)),
                  errorText: field.errorText,
                ),
                itemSubmitted: (item) {
                  setState(() {
                    selectedMember = item;
                    textEditingControllerMember.text = item.memberNumber;
                    field.didChange(item.id);

                    getMemberTransaction();
                  });
                },
                key: keyMember,
                suggestions: savingMembers!,
                itemBuilder: (context, suggestion) {
                  return Padding(
                      child: ListTile(title: Text(suggestion.memberNumber)),
                      padding: EdgeInsets.all(8.0));
                },
                itemSorter: (a, b) => 0,
                itemFilter: (suggestion, input) => suggestion.memberNumber
                    .toLowerCase()
                    .startsWith(input.toLowerCase()),
                clearOnSubmit: false,
                controller: textEditingControllerMember,
              );
            },
          );

    var amountField = FormBuilderTextField(
      name: "amount",
      decoration: InputDecoration(
          labelText: "Amount",
          hintText: "Amount",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5))),
      validator: FormBuilderValidators.compose([
        FormBuilderValidators.required(),
      ]),
    );

    var crOrDebField = FormBuilderRadioGroup<String>(
      decoration: const InputDecoration(
        labelText: 'Credit or Debit',
      ),
      initialValue: null,
      name: 'status',
      onChanged: (val) => null,
      validator:
          FormBuilderValidators.compose([FormBuilderValidators.required()]),
      options: ['Credit', 'Debit']
          .map((lang) => FormBuilderFieldOption(
                value: lang.toLowerCase(),
                child: Text(lang),
              ))
          .toList(growable: false),
      controlAffinity: ControlAffinity.trailing,
    );

    var memberDetailsWidget = selectedMember == null
        ? Container()
        : Column(
            children: [
              Row(
                children: [
                  SizedBox(
                      width: 70,
                      child: Text("Name: ",
                          style:
                              TextStyle(fontSize: 16, color: Colors.black38))),
                  Expanded(
                    child: Text(
                      selectedMember!.memberName,
                      style: TextStyle(fontSize: 16),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  SizedBox(
                      width: 70,
                      child: Text("NIC: ",
                          style:
                              TextStyle(fontSize: 16, color: Colors.black38))),
                  Text(selectedMember!.nic, style: TextStyle(fontSize: 16))
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  SizedBox(
                      width: 70,
                      child: Text("Mobile: ",
                          style:
                              TextStyle(fontSize: 16, color: Colors.black38))),
                  Text(selectedMember!.mobile, style: TextStyle(fontSize: 16))
                ],
              ),
            ],
          );

    var buttonsWidget = Row(
      children: <Widget>[
        Expanded(
          child: ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState?.saveAndValidate() ?? false) {
                createRecord();
              } else {
                debugPrint(_formKey.currentState?.value.toString());
                debugPrint('validation failed');
              }
            },
            child: const Text(
              'Submit',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              _formKey.currentState?.reset();
              setState(() {
                textEditingControllerMember.text = "";
                selectedMember = null;
              });
            },
            // color: Theme.of(context).colorScheme.secondary,
            child: Text(
              'Reset',
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            ),
          ),
        ),
      ],
    );

    var balanceWidget = selectedMember == null
        ? Container()
        : Center(
            child: Column(
              children: [
                Text(
                  "Balance",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                (savingBalance == null)
                    ? CircularProgressIndicator()
                    : Text(
                        '$savingBalance/=',
                        style: TextStyle(
                            color: Colors.green,
                            fontSize: 26,
                            fontWeight: FontWeight.bold),
                      )
              ],
            ),
          );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0.0,
        centerTitle: true,
        title: Text("Savings"),
        actions: [Logout()],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 150.0,
                  decoration: const BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30.0),
                        bottomRight: Radius.circular(30.0),
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20.0),
                      welcomeText,
                      const SizedBox(height: 10.0),
                      const Text("Add Transaction",
                          style:
                              TextStyle(fontSize: 16.0, color: Colors.white)),
                      const SizedBox(
                        height: 50.0,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  FormBuilder(
                      key: _formKey,
                      onChanged: () {
                        _formKey.currentState!.save();
                        debugPrint(_formKey.currentState!.value.toString());
                      },
                      autovalidateMode: AutovalidateMode.disabled,
                      child: Column(
                        children: [
                          memberNumbersField,
                          SizedBox(
                            height: 10,
                          ),
                          amountField,
                          SizedBox(
                            height: 10,
                          ),
                          crOrDebField,
                          SizedBox(
                            height: 10,
                          ),
                          buttonsWidget
                        ],
                      )),
                  SizedBox(
                    height: 20,
                  ),
                  memberDetailsWidget,
                  SizedBox(
                    height: 20,
                  ),
                  balanceWidget
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  createRecord() {
    //show loader
    showLoadingDialog(context);

    var batch = databaseReference.batch();

    DateTime now = DateTime.now();

    storage.read(key: "branchId").then((branchId) {
      //add transaction
      var savingTransactionsRef = databaseReference
          .collection("saving_transactions")
          .doc(now.millisecondsSinceEpoch.toString());

      batch.set(savingTransactionsRef, {
        'amount': _formKey.currentState!.value["amount"],
        'dateTime': now,
        'memberId': _formKey.currentState!.value["memberId"],
        'status': _formKey.currentState!.value["status"]
      });

      //add log
      var transactionLogRef = databaseReference
          .collection("saving_logs")
          .doc(now.millisecondsSinceEpoch.toString());

      batch.set(transactionLogRef, {
        'branch': branchId,
        'date': now,
        'log': 'New transaction added to the system. '
            'Member Name ${selectedMember!.memberName} - '
            '${selectedMember!.memberNumber} - '
            'Amount: ${_formKey.currentState!.value["amount"]} - '
            'Status: ${_formKey.currentState!.value["status"]}',
        'operator': _userName,
        'type': 'transactions'
      });

      //commit batch
      batch.commit().then((value) {
        //hide loader
        Navigator.of(context).pop();

        showSuccessMsg(context, "Transaction added successfully");

        String status = _formKey.currentState!.value["status"].toString();
        String amount = _formKey.currentState!.value["amount"].toString();

        //calculate new balance
        double balance = 0;
        if (status == "credit")
          balance = double.parse(savingBalance!) + double.parse(amount);
        else
          balance = double.parse(savingBalance!) - double.parse(amount);

        //print slip
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PrintSlip(
                    amount: amount,
                    status: status,
                    member: selectedMember!,
                    balance: balance.toStringAsFixed(2))));
      }).catchError((onError) {
        //hide loader
        Navigator.of(context).pop();

        showErrorMsg(context, onError.toString());
      });
    });
  }
}
