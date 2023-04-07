package mff.example.application;

import androidx.appcompat.app.AppCompatActivity;

import android.os.Bundle;
import android.util.Log;
import android.view.View;

public class mffActivity extends AppCompatActivity implements View.OnClickListener, View.OnLayoutChangeListener {

    // Used to load the 'mff-app' library on application startup.
    static {
        try {
            System.loadLibrary("mff-app");
        } catch (Exception ex) {
            Log.println(0, "log_tag", ex.getMessage());
        }
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        onCreate(findViewById(R.id.layout));

        // Example of a call to a native method
        //Button btn = findViewById(R.id.button7);
        //btn.setText(stringFromJNI());
    }

    @Override
    protected void onStart() {
        super.onStart();
    }

    @Override
    protected void onResume() {
        super.onResume();
    }

    @Override
    protected void onPause() {
        super.onPause();
    }

    @Override
    protected void onStop() {
        super.onStop();
    }

    @Override
    protected void onRestart() {
        super.onRestart();
    }

    @Override
    protected void onDestroy() {
        onDestroy(findViewById(R.id.layout));
        super.onDestroy();
    }

    /**
     * A native method that is implemented by the 'native-lib' native library,
     * which is packaged with this application.
     */
    public native void onCreate(Object layout);

    public native void onDestroy(Object layout);

    @Override
    public native void onClick(View view);

    @Override
    public native void onLayoutChange(View v, int left, int top, int right, int bottom, int oldLeft, int oldTop, int oldRight, int oldBottom);
}
