class Users {
  String id, name, email, phone;
  Users({this.id = '', this.email = '', this.name = '', this.phone = ''});

  // Users.fromSnapshot(DataSnapshot snapshot) {
  //   id = snapshot.key!;
  //   email = snapshot.value['email'];
  //   name = snapshot.value['name'];
  //   phone = snapshot.value['phone'];
  // }
}
