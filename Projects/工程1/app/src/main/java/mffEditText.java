package mff.example.application;

import android.content.Context;
import android.text.Editable;
import android.text.TextWatcher;
import android.widget.EditText;

public class mffEditText extends EditText implements TextWatcher {
    public mffEditText(Context context) {
        super(context);
    }

    public void afterTextChanged(Editable s) {
    }

    public void beforeTextChanged(CharSequence s, int start, int count,
                                  int after) {
    }

    public native void onTextChanged(CharSequence s, int start, int before, int count);
}
