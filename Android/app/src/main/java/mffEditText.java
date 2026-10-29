package com.visualfbeditor.ide;

import android.content.Context;
import android.text.Editable;
import android.text.TextWatcher;
import android.widget.EditText;

public class mffEditText extends EditText implements TextWatcher {
    public mffEditText(Context context) {
        super(context);
        // The height comes from the form (SetBounds): no minimum height of the theme (48dp) and a small vertical padding,
        // else the text is cut in a TextBox of the designer height (about 30)
        setMinHeight(0);
        setMinimumHeight(0);
        int dp2 = Math.round(2 * context.getResources().getDisplayMetrics().density);
        setPadding(getPaddingLeft(), dp2, getPaddingRight(), dp2);
        setGravity(android.view.Gravity.CENTER_VERTICAL | android.view.Gravity.START);
    }

    public void afterTextChanged(Editable s) {
    }

    public void beforeTextChanged(CharSequence s, int start, int count,
                                  int after) {
    }

    public native void onTextChanged(CharSequence s, int start, int before, int count);
}
