//Functions validate input string passed as an argument
// and returns int for index for use in SwitchLanguage list

class Validators {

  //Sign Up page email validator
  String accountNameValidator(String val) {
    if (val.isNotEmpty) {
      if (RegExp(r'^[a-zA-Z0-9]+$').hasMatch(val)) {
        if (val.length > 32) {
          return 'T19'; ///'Maximum length of the name is 32 characters'
        } else {
          return 'null';//null for validation
        }
      } else {
        return 'T18'; ///'Please use only English letters and numbers'

      }
    } else {
      return 'T01'; ///'This field is required'
    }
  }

  //Sign Up page email validator
  String emailSignUpValidator(String val) {
    if (val.isNotEmpty) {
      // r"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,64}"
      //RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email)
      //if (val.contains(RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+"))) {
      if (RegExp(r"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,64}").hasMatch(val)) {
        return 'null';//null for validation
      } else {
        return 'T00'; ///'Please enter a valid email address'
      }
    } else {
      return 'T01'; ///'This field is required'
    }
  }

  //Sign Up page password validator
  String passwordSignUpValidator(String val) {
    if (val.isNotEmpty) {
      if (val.length > 7) {
        return 'null';//null for validation
      } else {
        return 'T02'; ///'Password must contain at least 8 characters'
      }
    } else {
      return 'T01'; ///'This field is required'
    }
  }

  //Sign Up page repeat password validator
  String repeatPasswordSignUpValidator(String val, String val1) {
    if (val == val1) {
      return 'null';//null for validation
    } else {
      return 'T12'; ///'The passwords do not match'
    }
  }

}