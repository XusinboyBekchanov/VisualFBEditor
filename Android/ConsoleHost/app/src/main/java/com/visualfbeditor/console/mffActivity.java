package com.visualfbeditor.console;

// The console of a FreeBASIC program without an Android project, which the Android IDE compiles on the Web IDE
// Server (WebCompile of TabWindow.bas): the program is the executable libconsole-app.so of the native libraries of
// the app (an app can run files only from there). Its output (Print) is shown here, a line of the text box is its
// input (Input, GetKey). The name of the class is the one which the server starts (RunPr of TabWindow.bas)

import android.app.Activity;
import android.graphics.Typeface;
import android.os.Bundle;
import android.text.InputType;
import android.view.KeyEvent;
import android.view.View;
import android.view.inputmethod.EditorInfo;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.TextView;

import java.io.File;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.Reader;
import java.nio.charset.StandardCharsets;

public class mffActivity extends Activity {
    private TextView output;
    private ScrollView scroll;
    private EditText input;
    private Button enter;
    private Process process;
    private OutputStream stdin;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        int padding = (int) (8 * getResources().getDisplayMetrics().density);
        LinearLayout root = new LinearLayout(this);
        root.setOrientation(LinearLayout.VERTICAL);
        scroll = new ScrollView(this);
        output = new TextView(this);
        output.setTypeface(Typeface.MONOSPACE);
        output.setTextIsSelectable(true);
        output.setPadding(padding, padding, padding, padding);
        scroll.addView(output);
        root.addView(scroll, new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, 0, 1));
        LinearLayout bar = new LinearLayout(this);
        bar.setOrientation(LinearLayout.HORIZONTAL);
        input = new EditText(this);
        input.setSingleLine(true);
        input.setInputType(InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_FLAG_NO_SUGGESTIONS);
        input.setImeOptions(EditorInfo.IME_ACTION_SEND);
        input.setOnEditorActionListener(new TextView.OnEditorActionListener() {
            @Override
            public boolean onEditorAction(TextView v, int actionId, KeyEvent event) {
                sendLine();
                return true;
            }
        });
        enter = new Button(this);
        enter.setText("Enter");
        enter.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                sendLine();
            }
        });
        bar.addView(input, new LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1));
        bar.addView(enter, new LinearLayout.LayoutParams(LinearLayout.LayoutParams.WRAP_CONTENT, LinearLayout.LayoutParams.WRAP_CONTENT));
        root.addView(bar, new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT));
        setContentView(root);
        startProgram();
    }

    private void startProgram() {
        File program = new File(getApplicationInfo().nativeLibraryDir, "libconsole-app.so");
        try {
            ProcessBuilder builder = new ProcessBuilder(program.getAbsolutePath());
            builder.directory(getFilesDir());
            builder.environment().put("HOME", getFilesDir().getAbsolutePath());
            builder.environment().put("TERM", "dumb");
            builder.redirectErrorStream(true);
            process = builder.start();
            stdin = process.getOutputStream();
        } catch (Exception ex) {
            append("Unable to start " + program + ": " + ex + "\n");
            finished();
            return;
        }
        Thread reader = new Thread(new Runnable() {
            @Override
            public void run() {
                char[] buffer = new char[4096];
                try (Reader stdout = new InputStreamReader(process.getInputStream(), StandardCharsets.UTF_8)) {
                    int count;
                    while ((count = stdout.read(buffer)) > 0) {
                        append(new String(buffer, 0, count));
                    }
                } catch (Exception ex) {
                    // the stream is closed when the program ends
                }
                int exitCode;
                try {
                    exitCode = process.waitFor();
                } catch (InterruptedException ex) {
                    return;
                }
                append("\n[" + exitCode + "]\n");
                finished();
            }
        });
        reader.setDaemon(true);
        reader.start();
    }

    // The text of the program: Cls (ESC[2J) clears the console, the other sequences of the terminal are not shown
    private void append(final String text) {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                String rest = text;
                int clear = rest.lastIndexOf("\u001B[2J");
                if (clear >= 0) {
                    output.setText("");
                    rest = rest.substring(clear + 4);
                }
                output.append(rest.replaceAll("\u001B\\[[0-9;?]*[A-Za-z]", "").replace("\r\n", "\n"));
                scroll.post(new Runnable() {
                    @Override
                    public void run() {
                        scroll.fullScroll(View.FOCUS_DOWN);
                    }
                });
            }
        });
    }

    private void finished() {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                input.setEnabled(false);
                enter.setEnabled(false);
            }
        });
    }

    // The line goes to the input of the program (Enter of a keyboard) and is shown after the prompt of Input (the
    // runtime of FreeBASIC does not echo it without a real terminal)
    private void sendLine() {
        if (stdin == null) return;
        String line = input.getText().toString();
        input.setText("");
        append(line + "\n");
        try {
            stdin.write((line + "\n").getBytes(StandardCharsets.UTF_8));
            stdin.flush();
        } catch (Exception ex) {
            append("[" + ex.getMessage() + "]\n");
        }
    }

    @Override
    protected void onDestroy() {
        if (process != null) process.destroy();
        super.onDestroy();
    }
}
