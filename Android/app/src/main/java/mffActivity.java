package com.visualfbeditor.ide;

import androidx.appcompat.app.AppCompatActivity;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;
import android.graphics.Color;
import android.graphics.drawable.GradientDrawable;
import android.util.Log;
import android.util.TypedValue;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AbsoluteLayout;
import android.widget.Adapter;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.AbsListView;
import android.widget.BaseAdapter;
import android.widget.ImageButton;
import android.widget.ListView;
import android.widget.Spinner;
import android.os.Build;
import android.text.method.LinkMovementMethod;
import android.view.Gravity;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.Button;
import android.widget.DatePicker;
import android.widget.HorizontalScrollView;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.NumberPicker;
import android.widget.ProgressBar;
import android.widget.ScrollView;
import android.widget.SeekBar;
import android.widget.TextView;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;

public class mffActivity extends AppCompatActivity implements View.OnClickListener, View.OnLayoutChangeListener,
        AdapterView.OnItemSelectedListener, AdapterView.OnItemClickListener,
        SeekBar.OnSeekBarChangeListener, NumberPicker.OnValueChangeListener {

    // The library is loaded in attachBaseContext (loadNativeLibrary): its module code runs when it is loaded, and the
    // files of the app (prepareAppFiles) and the environment must be ready before.
    private static boolean nativeLibraryLoaded;
    // this activity loaded the library (the first one of the process)
    private boolean nativeLibraryLoader;

    private void loadNativeLibrary(Context context) {
        if (nativeLibraryLoaded) return;
        nativeLibraryLoader = true;
        prepareAppFiles(context);
        try {
            System.loadLibrary("mff-app");
            nativeLibraryLoaded = true;
        } catch (Throwable ex) {
            Log.e("mff", "loadLibrary: " + ex);
        }
    }

    // The data files of the program (Open, IniFile, ExePath of the program, ...) are the asset mffapp.zip of the APK:
    // they are copied to the folder files/mffapp of the app at the first start and after an update. The FreeBasic side
    // finds the folder in the environment variable MFF_APPDIR; HOME and TMPDIR are the folders of the app.
    private static void prepareAppFiles(Context context) {
        java.io.File dir = new java.io.File(context.getFilesDir(), "mffapp");
        try {
            boolean hasZip = false;
            String[] assets = context.getAssets().list("");
            if (assets != null) for (String name : assets) if (name.equals("mffapp.zip")) hasZip = true;
            if (hasZip) {
                String stamp = String.valueOf(context.getPackageManager().getPackageInfo(context.getPackageName(), 0).lastUpdateTime);
                java.io.File mark = new java.io.File(dir, ".mffapp");
                String old = "";
                if (mark.exists()) {
                    java.io.BufferedReader r = new java.io.BufferedReader(new java.io.FileReader(mark));
                    old = r.readLine();
                    r.close();
                }
                if (!stamp.equals(old)) {
                    java.util.zip.ZipInputStream zip = new java.util.zip.ZipInputStream(new java.io.BufferedInputStream(context.getAssets().open("mffapp.zip")));
                    byte[] buffer = new byte[65536];
                    String root = dir.getCanonicalPath() + java.io.File.separator;
                    java.util.zip.ZipEntry entry;
                    while ((entry = zip.getNextEntry()) != null) {
                        java.io.File file = new java.io.File(dir, entry.getName());
                        if (!file.getCanonicalPath().startsWith(root)) continue;
                        if (entry.isDirectory()) {
                            file.mkdirs();
                        } else {
                            java.io.File parent = file.getParentFile();
                            if (parent != null) parent.mkdirs();
                            java.io.OutputStream out = new java.io.FileOutputStream(file);
                            int n;
                            while ((n = zip.read(buffer)) > 0) out.write(buffer, 0, n);
                            out.close();
                        }
                    }
                    zip.close();
                    java.io.FileWriter w = new java.io.FileWriter(mark);
                    w.write(stamp);
                    w.close();
                }
            }
            dir.mkdirs();
            if (Build.VERSION.SDK_INT >= 21) {
                android.system.Os.setenv("MFF_APPDIR", dir.getAbsolutePath(), true);
                String home = android.system.Os.getenv("HOME");
                if (home == null || home.isEmpty() || home.equals("/")) android.system.Os.setenv("HOME", context.getFilesDir().getAbsolutePath(), true);
                android.system.Os.setenv("TMPDIR", context.getCacheDir().getAbsolutePath(), true);
                // The documents of the user (%USERDOCUMENTS%, GetSpecialPath): the folder Documents of the app on the
                // shared storage (no permission, seen with a computer over USB), else the one in the folder of the app
                java.io.File documents = context.getExternalFilesDir(android.os.Environment.DIRECTORY_DOCUMENTS);
                if (documents == null) documents = new java.io.File(context.getFilesDir(), "Documents");
                documents.mkdirs();
                android.system.Os.setenv("MFF_DOCUMENTS", documents.getAbsolutePath(), true);
            }
        } catch (Exception ex) {
            Log.e("mff", "prepareAppFiles: " + ex);
        }
    }

    // Configured from FreeBasic side via the Form.ExternalEventAction / Form.ExternalEventExtra
    // properties (see updateExternalEventFilter below) — no need to edit this file.
    private String scannerIntentExtra = "";
    private boolean scannerReceiverRegistered = false;

    private final BroadcastReceiver scannerReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            String data = intent.getStringExtra(scannerIntentExtra);
            if (data == null) {
                // fall back to the first string extra found, in case the scanner
                // uses a different extra name than the configured one
                Bundle extras = intent.getExtras();
                if (extras != null) {
                    for (String key : extras.keySet()) {
                        Object value = extras.get(key);
                        if (value instanceof String) {
                            data = (String) value;
                            break;
                        }
                    }
                }
            }
            if (data != null) {
                onExternalEvent(data);
            }
        }
    };

    // The library is loaded before AppCompat makes the configuration of the activity (in its attachBaseContext): the
    // night mode of the program (App.DarkMode, SetDarkMode of DarkMode.bas) is set by its module code in MFF_DARKMODE
    @Override
    protected void attachBaseContext(Context base) {
        if (!nativeLibraryLoaded) {
            loadNativeLibrary(base);
            String darkMode = Build.VERSION.SDK_INT >= 21 ? android.system.Os.getenv("MFF_DARKMODE") : null;
            if ("1".equals(darkMode)) androidx.appcompat.app.AppCompatDelegate.setDefaultNightMode(androidx.appcompat.app.AppCompatDelegate.MODE_NIGHT_YES);
            else if ("0".equals(darkMode)) androidx.appcompat.app.AppCompatDelegate.setDefaultNightMode(androidx.appcompat.app.AppCompatDelegate.MODE_NIGHT_NO);
        }
        super.attachBaseContext(base);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        // The forms of the native side are made once in the process for the first activity (its views): Android
        // destroyed that activity (Don't keep activities, the memory) and the process stayed, a new activity would be
        // empty. The program starts again in a new process
        if (nativeLibraryLoaded && !nativeLibraryLoader) {
            super.onCreate(savedInstanceState);
            restartApplication();
            return;
        }
        instance = this;
        super.onCreate(savedInstanceState);
        updateNightMode(getResources().getConfiguration());
        setContentView(R.layout.activity_main);

        // The forms of the native side are made when the activity is resumed: a MsgBox or a ShowModal of the program
        // (a nested message loop, modalRun) in onCreate would run the next steps of the life of the activity in it
        // (Back failed then: "Activity top position already set")
        final View layout = formLayout(findViewById(R.id.layout));
        new android.os.Handler(android.os.Looper.getMainLooper()).post(new Runnable() {
            @Override
            public void run() {
                onCreate(layout);
                // the items of the main menu (mainMenuCaptions) are made now
                invalidateOptionsMenu();
            }
        });

        // Example of a call to a native method
        //Button btn = findViewById(R.id.button7);
        //btn.setText(stringFromJNI());
    }

    /**
     * Called from the native library (FreeBasic side) whenever the Form's
     * ExternalEventAction / ExternalEventExtra properties are set. (Re)registers
     * the barcode scanner broadcast receiver with the given intent action and
     * extra key. Passing an empty/null action disables the receiver.
     */
    public void updateExternalEventFilter(String action, String extra) {
        if (scannerReceiverRegistered) {
            try {
                unregisterReceiver(scannerReceiver);
            } catch (Exception ex) {
                Log.println(0, "log_tag", ex.getMessage());
            }
            scannerReceiverRegistered = false;
        }
        scannerIntentExtra = extra != null ? extra : "";
        if (action != null && !action.isEmpty()) {
            registerReceiver(scannerReceiver, new IntentFilter(action));
            scannerReceiverRegistered = true;
        }
    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        // Some scanner apps/SDKs return data via startActivityForResult/onNewIntent
        // instead of a broadcast. Forward it the same way if present.
        if (intent != null && scannerReceiverRegistered) {
            String data = intent.getStringExtra(scannerIntentExtra);
            if (data != null) {
                onExternalEvent(data);
            }
        }
    }

    // ---- A second form shown with Form.Show is a screen of its own: FormActivity (AndroidManifest.xml) shows the view
    // of the form (made by the native side in the layout of its owner) with the title in its action bar and the Up
    // button. Up and Back are the close button of the form (onListChange -1: Form.CloseForm, OnClose can keep it),
    // Form.Hide finishes the activity. A form of ShowModal is a full-screen dialog in this activity (formTitleBar)
    static mffActivity instance;
    private final HashMap<Integer, View> formViews = new HashMap<>();
    private final java.util.WeakHashMap<View, FormActivity> formActivities = new java.util.WeakHashMap<>();
    private FormActivity formTop;

    // False: FormActivity is not in AndroidManifest.xml, the form is a full-screen dialog
    public boolean formActivityShow(Object v, String title) {
        if (!(v instanceof View)) return false;
        View form = (View) v;
        FormActivity a = formActivities.get(form);
        if (a != null) {
            a.setTitle(title);
            return true;
        }
        Intent intent = new Intent(this, FormActivity.class).putExtra("form", form.getId()).putExtra("title", title);
        if (getPackageManager().resolveActivity(intent, 0) == null) return false;
        formViews.put(form.getId(), form);
        // the size of the form of the designer (the first time it is in its owner): its activity scrolls it when it is
        // smaller
        if (!formSizes.containsKey(form) && form.getLayoutParams() instanceof AbsoluteLayout.LayoutParams) {
            ViewGroup.LayoutParams lp = form.getLayoutParams();
            formSizes.put(form, new int[]{lp.width, lp.height});
        }
        // the form is not seen in its owner until its activity takes it
        if (form.getParent() instanceof ViewGroup) ((ViewGroup) form.getParent()).removeView(form);
        form.setVisibility(View.VISIBLE);
        startActivity(intent);
        // Like Show of Windows the form is seen when Show returns: the next MsgBox of the program is in its activity
        // (dialogOwner), not in this one behind it
        modalRun(formStarting);
        return true;
    }

    private final java.util.WeakHashMap<View, int[]> formSizes = new java.util.WeakHashMap<>();

    // The wait of formActivityShow until the activity of the form is resumed
    private final Object formStarting = new Object();

    private void formStarted() {
        modalEnd(formStarting);
    }

    public void formActivityTitle(Object v, String title) {
        FormActivity a = v instanceof View ? formActivities.get(v) : null;
        if (a != null) a.setTitle(title);
    }

    public void formActivityHide(Object v) {
        if (!(v instanceof View)) return;
        formViews.remove(((View) v).getId());
        FormActivity a = formActivities.get(v);
        if (a != null) a.finish();
    }

    // The dialogs (MsgBox, the file dialog, the popup menus, ...) are shown in the activity which is seen
    private android.app.Activity dialogOwner() {
        return formTop != null && !formTop.isFinishing() ? formTop : this;
    }

    public static class FormActivity extends AppCompatActivity {
        private View form;

        @Override
        protected void onCreate(Bundle savedInstanceState) {
            super.onCreate(savedInstanceState);
            mffActivity main = instance;
            form = main == null ? null : main.formViews.get(getIntent().getIntExtra("form", -1));
            // a new process (Android restored the activity): the forms of the native side are not made
            if (form == null) {
                if (main != null) main.formStarted();
                finish();
                return;
            }
            if (form.getParent() instanceof ViewGroup) ((ViewGroup) form.getParent()).removeView(form);
            form.setVisibility(View.VISIBLE);
            if (form instanceof MffScrollLayout) {
                // The form fills the screen, its controls are aligned in it (Anchor, Align) and it scrolls only the ones
                // which are outside of it
                setContentView(form, new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
                showForm(main);
                return;
            }
            // A form of an older library: a form larger than the screen is scrolled (also with the mouse wheel); a
            // smaller one fills it
            int[] size = main.formSizes.get(form);
            form.setMinimumWidth(size != null && size[0] > 0 ? size[0] : 0);
            form.setMinimumHeight(size != null && size[1] > 0 ? size[1] : 0);
            ScrollView vertical = new ScrollView(this);
            vertical.setFillViewport(true);
            HorizontalScrollView horizontal = new HorizontalScrollView(this);
            horizontal.setFillViewport(true);
            horizontal.addView(form, new android.widget.FrameLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.MATCH_PARENT));
            vertical.addView(horizontal, new android.widget.FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT));
            setContentView(vertical);
            showForm(main);
        }

        // The title and the Up button in the action bar, the style of the form (Form.ApplyAndroidStyle)
        private void showForm(mffActivity main) {
            setTitle(getIntent().getStringExtra("title"));
            if (getSupportActionBar() != null) getSupportActionBar().setDisplayHomeAsUpEnabled(true);
            Integer style = main.formStyles.get(form);
            if (style != null) applyFormStyle(this, style);
            main.formActivities.put(form, this);
        }

        @Override
        public void onWindowFocusChanged(boolean hasFocus) {
            super.onWindowFocusChanged(hasFocus);
            Integer style = instance == null || form == null ? null : instance.formStyles.get(form);
            if (hasFocus && style != null && (style & 2) != 0) applyFormStyle(this, style);
        }

        private void close() {
            if (instance != null && form != null) instance.onListChange(form, -1);
            else finish();
        }

        @Override
        public boolean onSupportNavigateUp() {
            close();
            return true;
        }

        @Override
        public void onBackPressed() {
            // the open list of a ComboBox, then a full-screen dialog (ShowModal) over the form is closed first
            if (closeSpinnerPopup(getWindow().getDecorView())) return;
            if (instance != null && instance.closeTopFormBar(this)) return;
            close();
        }

        @Override
        protected void onResume() {
            super.onResume();
            if (instance != null) {
                instance.formTop = this;
                instance.formStarted();
            }
        }

        @Override
        protected void onPause() {
            if (instance != null && instance.formTop == this) instance.formTop = null;
            super.onPause();
        }

        @Override
        protected void onDestroy() {
            if (form != null && instance != null) {
                if (instance.formActivities.get(form) == this) instance.formActivities.remove(form);
                // the view is free for the next Show (a new activity) or ShowModal (in the layout of its owner)
                if (form.getParent() instanceof ViewGroup) ((ViewGroup) form.getParent()).removeView(form);
                // finished without Form.Hide (the activity was removed from the recent tasks): the form is closed
                if (isFinishing() && instance.formViews.values().remove(form)) instance.onListChange(form, -1);
            }
            super.onDestroy();
        }
    }

    // Restart (in its own process, AndroidManifest.xml) ends this process and starts the activity in a new one.
    // Without it in the manifest the process only ends: the next start of the program is a new one
    public void restartApplication() {
        try {
            startActivity(new Intent(this, Restart.class).putExtra("pid", android.os.Process.myPid())
                    .putExtra("activity", Intent.makeRestartActivityTask(getComponentName())));
        } catch (Exception ex) {
            Log.e("mff", "restart: " + ex);
        }
        finish();
        Runtime.getRuntime().exit(0);
    }

    // The night mode of the theme DayNight (App.DarkMode, SetDarkMode of DarkMode.bas). The activities have uiMode in
    // configChanges (AndroidManifest.xml): they get onConfigurationChanged and are not made again, the views made
    // before keep their colors, the next ones are dark
    public void setDarkMode(boolean value) {
        androidx.appcompat.app.AppCompatDelegate.setDefaultNightMode(value ? androidx.appcompat.app.AppCompatDelegate.MODE_NIGHT_YES
                : androidx.appcompat.app.AppCompatDelegate.MODE_NIGHT_NO);
        updateNightMode(getResources().getConfiguration());
    }

    @Override
    public void onConfigurationChanged(android.content.res.Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
        updateNightMode(newConfig);
    }

    // The colors of the views made here (lists, tabs, toolbars, ...) in the night mode: night(light, dark)
    static boolean nightMode;

    static void updateNightMode(android.content.res.Configuration config) {
        // the mode of the program (setDarkMode); the configuration of onConfigurationChanged (a turn of the screen) is the
        // one of the system, not the night mode of AppCompat
        int mode = androidx.appcompat.app.AppCompatDelegate.getDefaultNightMode();
        if (mode == androidx.appcompat.app.AppCompatDelegate.MODE_NIGHT_YES) nightMode = true;
        else if (mode == androidx.appcompat.app.AppCompatDelegate.MODE_NIGHT_NO) nightMode = false;
        else nightMode = (config.uiMode & android.content.res.Configuration.UI_MODE_NIGHT_MASK) == android.content.res.Configuration.UI_MODE_NIGHT_YES;
    }

    public boolean isNightMode() {
        return nightMode;
    }

    static int night(int light, int dark) {
        return nightMode ? dark : light;
    }

    // The text of the lists and the buttons of the theme
    static int textColor() {
        return night(Color.BLACK, 0xFFE0E0E0);
    }

    // The activity of the process :mffrestart (AndroidManifest.xml): it ends the process of the program and starts
    // its activity again, Android starts it in a new process
    public static class Restart extends android.app.Activity {
        @Override
        protected void onCreate(Bundle savedInstanceState) {
            super.onCreate(savedInstanceState);
            android.os.Process.killProcess(getIntent().getIntExtra("pid", -1));
            Intent activity = getIntent().getParcelableExtra("activity");
            if (activity != null) startActivity(activity);
            finish();
        }
    }

    // Back does not close the activity: the forms of the native side stay in the process (onCreate makes them only
    // once), a new activity was empty. The app goes to the background like with Home and comes back as it was.
    // A shown second form (its title bar, formTitleBar) is closed first like with its close button
    @Override
    public void onBackPressed() {
        // the open list of a ComboBox first, then a dialog
        if (closeSpinnerPopup(getWindow().getDecorView())) return;
        if (closeTopFormBar(this)) return;
        moveTaskToBack(true);
    }

    // The full-screen dialog (ShowModal, formTitleBar) shown last in the activity is closed like with its close button
    private boolean closeTopFormBar(android.app.Activity activity) {
        View root = activity.getWindow().getDecorView();
        View top = null;
        for (View form : formBars.keySet()) {
            // also a form without its title bar (BorderStyle None)
            if (form.getVisibility() != View.VISIBLE || !(form.getParent() instanceof ViewGroup) || form.getRootView() != root) continue;
            // the last one over the others
            if (top == null || (form.getParent() == top.getParent() && indexInParent(form) > indexInParent(top))) top = form;
        }
        if (top == null) return false;
        onListChange(top, -1);
        return true;
    }

    private static int indexInParent(View v) {
        return ((ViewGroup) v.getParent()).indexOfChild(v);
    }

    @Override
    protected void onDestroy() {
        if (scannerReceiverRegistered) {
            try {
                unregisterReceiver(scannerReceiver);
            } catch (Exception ex) {
                Log.println(0, "log_tag", ex.getMessage());
            }
            scannerReceiverRegistered = false;
        }
        super.onDestroy();
    }

    // ---- Helpers called from the native (FreeBasic) side ----------------------------------
    // ComboBoxEdit is a Spinner, ListControl is a ListView; both use an ArrayAdapter<String>.

    // Spinners report the initial selection once they are laid out; that is not a user change.
    private final HashSet<View> armedSpinners = new HashSet<>();

    @SuppressWarnings("unchecked")
    private static ArrayAdapter<String> adapterOf(View v) {
        if (v instanceof AdapterView) {
            Adapter a = ((AdapterView<?>) v).getAdapter();
            // the adapter of a table with a header row (tableSetColumns) is wrapped
            if (a instanceof android.widget.HeaderViewListAdapter) a = ((android.widget.HeaderViewListAdapter) a).getWrappedAdapter();
            if (a instanceof ArrayAdapter) return (ArrayAdapter<String>) a;
        }
        return null;
    }

    // The rows of a ListView with a header row (the captions of the columns of a table) begin after it: the indexes of
    // the native side are the ones of the rows
    private static int headerRows(View v) {
        return v instanceof ListView ? ((ListView) v).getHeaderViewsCount() : 0;
    }

    // ---- Tables (TreeView, ListView, TreeListView, Grid: TableSetColumns of SysUtils.bas): a row is the cells
    // separated by '\t' in the widths of the columns (in the units of the native side), the captions of the columns are
    // the header row of the ListView
    private final HashMap<View, int[]> tableWidths = new HashMap<>();
    private final HashMap<View, View> tableHeaders = new HashMap<>();

    public void tableSetColumns(View v, String captions, String widths) {
        if (!(v instanceof ListView)) return;
        ListView lv = (ListView) v;
        int[] w = null;
        if (widths != null && !widths.isEmpty()) {
            String[] parts = widths.split("\n", -1);
            w = new int[parts.length];
            float d = getResources().getDisplayMetrics().density;
            for (int i = 0; i < parts.length; i++) {
                try {
                    w[i] = Math.round(Float.parseFloat(parts[i].trim()) * d);
                } catch (NumberFormatException e) {
                    w[i] = dp(80);
                }
            }
        }
        if (w == null) tableWidths.remove(lv); else tableWidths.put(lv, w);
        View old = tableHeaders.remove(lv);
        if (old != null) lv.removeHeaderView(old);
        if (captions != null && !captions.isEmpty() && w != null) {
            View header = tableRow(null, captions.split("\n", -1), w, true);
            lv.addHeaderView(header, null, false);
            tableHeaders.put(lv, header);
        }
        ArrayAdapter<String> a = adapterOf(lv);
        if (a != null) a.notifyDataSetChanged();
    }

    // A row of a table: the cells in the widths of the columns (the last one is a little wider: the rest of the row);
    // header - the captions of the columns
    private LinearLayout tableRow(View convertView, String[] cells, int[] widths, boolean header) {
        LinearLayout row = convertView instanceof LinearLayout && "mffTableRow".equals(convertView.getTag())
                && ((LinearLayout) convertView).getChildCount() == widths.length ? (LinearLayout) convertView : null;
        if (row == null) {
            row = new LinearLayout(this);
            row.setTag("mffTableRow");
            row.setOrientation(LinearLayout.HORIZONTAL);
            for (int i = 0; i < widths.length; i++) {
                TextView t = defaultText(new TextView(this));
                t.setSingleLine(true);
                t.setEllipsize(android.text.TextUtils.TruncateAt.END);
                t.setPadding(dp(4), dp(3), dp(4), dp(3));
                t.setDuplicateParentStateEnabled(true);
                if (header) {
                    t.setTextColor(textColor());
                    GradientDrawable cell = new GradientDrawable();
                    cell.setColor(night(0xFFF0F0F0, 0xFF333337));
                    cell.setStroke(Math.max(1, dp(1) / 2), night(0xFFD0D0D0, 0xFF4A4A4F));
                    t.setBackground(cell);
                } else {
                    t.setTextColor(new android.content.res.ColorStateList(
                            new int[][]{{android.R.attr.state_activated}, {}}, new int[]{Color.WHITE, textColor()}));
                }
                // the last cell is the rest of the row
                boolean last = i == widths.length - 1;
                if (last) t.setMinWidth(widths[i]);
                row.addView(t, new LinearLayout.LayoutParams(last ? 0 : widths[i], ViewGroup.LayoutParams.WRAP_CONTENT, last ? 1f : 0f));
            }
            if (!header) {
                // the lines between the cells (the grid lines of a property grid)
                GradientDrawable line = new GradientDrawable();
                line.setColor(night(0xFFE0E0E0, 0xFF3F3F46));
                line.setSize(Math.max(1, dp(1) / 2), 1);
                row.setDividerDrawable(line);
                row.setShowDividers(LinearLayout.SHOW_DIVIDER_MIDDLE);
                // the chosen row (setItemChecked: activated) is like the selected item of a list of Windows
                android.graphics.drawable.StateListDrawable back = new android.graphics.drawable.StateListDrawable();
                back.addState(new int[]{android.R.attr.state_activated}, new android.graphics.drawable.ColorDrawable(0xFF0078D7));
                back.addState(new int[]{}, new android.graphics.drawable.ColorDrawable(Color.TRANSPARENT));
                row.setBackground(back);
            }
        }
        for (int i = 0; i < widths.length; i++) {
            TextView t = (TextView) row.getChildAt(i);
            t.setText(textWithPictures(i < cells.length ? cells[i] : "", t.getTextSize()));
        }
        return row;
    }

    // The adapter of a table: the rows have cells when the columns are known (tableSetColumns)
    private ArrayAdapter<String> tableAdapter(final AbsListView lv) {
        return new ArrayAdapter<String>(this, android.R.layout.simple_list_item_activated_1, new ArrayList<String>()) {
            @Override
            public View getView(int position, View convertView, ViewGroup parent) {
                int[] w = tableWidths.get(lv);
                String item = getItem(position);
                if (lv instanceof android.widget.GridView) return iconCell(convertView, item == null ? "" : item);
                if (w == null) {
                    View v = compactRow(super.getView(position, convertView instanceof TextView ? convertView : null, parent));
                    if (v instanceof TextView) ((TextView) v).setText(textWithPictures(item == null ? "" : item.replace("\t", "    "), ((TextView) v).getTextSize()));
                    return v;
                }
                return tableRow(convertView, (item == null ? "" : item).split("\t", -1), w, false);
            }
        };
    }

    // A cell of the icon view (ListView of View vsIcon): the picture of the item ("\u0001file\u0001" before the text of
    // its first cell, ListView.RowCells) above the text; the chosen cell is like the selected item of Windows
    private LinearLayout iconCell(View convertView, String item) {
        LinearLayout cell = convertView instanceof LinearLayout && "mffIconCell".equals(convertView.getTag()) ? (LinearLayout) convertView : null;
        if (cell == null) {
            cell = new LinearLayout(this);
            cell.setTag("mffIconCell");
            cell.setOrientation(LinearLayout.VERTICAL);
            cell.setGravity(Gravity.CENTER_HORIZONTAL);
            cell.setPadding(dp(2), dp(4), dp(2), dp(4));
            android.widget.ImageView picture = new android.widget.ImageView(this);
            picture.setScaleType(android.widget.ImageView.ScaleType.FIT_CENTER);
            cell.addView(picture, new LinearLayout.LayoutParams(dp(32), dp(32)));
            TextView t = defaultText(new TextView(this));
            t.setGravity(Gravity.CENTER_HORIZONTAL);
            t.setMaxLines(2);
            t.setEllipsize(android.text.TextUtils.TruncateAt.END);
            t.setPadding(dp(2), dp(2), dp(2), 0);
            t.setDuplicateParentStateEnabled(true);
            t.setTextColor(new android.content.res.ColorStateList(
                    new int[][]{{android.R.attr.state_activated}, {}}, new int[]{Color.WHITE, textColor()}));
            cell.addView(t, new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT));
            android.graphics.drawable.StateListDrawable back = new android.graphics.drawable.StateListDrawable();
            back.addState(new int[]{android.R.attr.state_activated}, new android.graphics.drawable.ColorDrawable(0xFF0078D7));
            back.addState(new int[]{}, new android.graphics.drawable.ColorDrawable(Color.TRANSPARENT));
            cell.setBackground(back);
        }
        String text = item;
        int tab = text.indexOf('\t');
        if (tab >= 0) text = text.substring(0, tab);
        android.graphics.drawable.Drawable d = null;
        if (text.startsWith("\u0001")) {
            int end = text.indexOf('\u0001', 1);
            if (end > 0) {
                d = buttonPicture(text.substring(1, end));
                text = text.substring(end + 1);
            }
        }
        android.widget.ImageView picture = (android.widget.ImageView) cell.getChildAt(0);
        picture.setImageDrawable(d);
        picture.setVisibility(d == null ? View.INVISIBLE : View.VISIBLE);
        ((TextView) cell.getChildAt(1)).setText(text);
        return cell;
    }

    // The rectangle of the cell (row, col) of a table in the pixels of the view: "left top right bottom", "" - the row
    // is not shown (TableCellRect of SysUtils.bas: the editor of a cell, the property grid of the IDE)
    public String tableCellRect(View v, int row, int col) {
        if (!(v instanceof ListView)) return "";
        ListView lv = (ListView) v;
        View r = lv.getChildAt(row + headerRows(lv) - lv.getFirstVisiblePosition());
        if (r == null) return "";
        int left = 0, right = lv.getWidth();
        int[] w = tableWidths.get(lv);
        if (w != null && col >= 0) {
            for (int i = 0; i < col && i < w.length; i++) left += w[i];
            right = col < w.length - 1 ? left + w[Math.min(col, w.length - 1)] : lv.getWidth();
        }
        return left + " " + r.getTop() + " " + right + " " + r.getBottom();
    }

    // The size of the text of the views in pixels: the default font of the program (DefaultFont, textSetDefaultSize),
    // the views which are made here (tabs, buttons of toolbars, rows of lists) take it too
    private float defaultTextPx;

    public void textSetDefaultSize(double px) {
        if (px > 0) defaultTextPx = (float) px;
    }

    private float defaultTextPx() {
        // 8 pt of Windows (DefaultFont) until the native side sets it
        if (defaultTextPx <= 0) defaultTextPx = TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 8f * 96 / 72, getResources().getDisplayMetrics());
        return defaultTextPx;
    }

    private <T extends TextView> T defaultText(T t) {
        t.setTextSize(TypedValue.COMPLEX_UNIT_PX, defaultTextPx());
        return t;
    }

    // The rows of the lists of Android are high (48dp) with a large text: they are of the size of the default font
    // (the rows of the list of a Spinner have the height in their layout params)
    private View compactRow(View v) {
        if (v instanceof TextView) {
            TextView t = defaultText((TextView) v);
            t.setMinHeight(0);
            t.setMinimumHeight(0);
            t.setPadding(dp(6), dp(3), dp(6), dp(3));
            ViewGroup.LayoutParams lp = t.getLayoutParams();
            if (lp != null && lp.height > 0) {
                lp.height = ViewGroup.LayoutParams.WRAP_CONTENT;
                t.setLayoutParams(lp);
            }
            t.setText(textWithPictures(t.getText(), t.getTextSize()));
        }
        return v;
    }

    // "...\u0001file\u0001...": the picture file is shown in the text (the rows of TreeView, ListView, TreeListView
    // and ComboBoxEx, FindResourceFile); an empty or missing file is left out
    private CharSequence textWithPictures(CharSequence text, float textPx) {
        if (text == null) return "";
        String s = text.toString();
        int start = s.indexOf('\u0001');
        if (start < 0) return text;
        android.text.SpannableStringBuilder b = new android.text.SpannableStringBuilder();
        int from = 0;
        while (start >= 0) {
            int end = s.indexOf('\u0001', start + 1);
            if (end < 0) break;
            b.append(s, from, start);
            // ":check" - the check mark of a checked item of a menu, ":blank" - the place of a picture (popupMenu)
            String file = s.substring(start + 1, end);
            android.graphics.drawable.Drawable d = file.equals(":blank") ? new android.graphics.drawable.ColorDrawable(Color.TRANSPARENT)
                    : file.equals(":check") ? checkMark() : file.startsWith(":on:") ? checkedPicture(buttonPicture(file.substring(4))) : buttonPicture(file);
            if (d != null) {
                int size = Math.round(textPx * 1.25f);
                d.setBounds(0, 0, size, size);
                int at = b.length();
                b.append("￼ ");
                b.setSpan(new android.text.style.ImageSpan(d, android.text.style.DynamicDrawableSpan.ALIGN_BOTTOM), at, at + 1, android.text.Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
            }
            from = end + 1;
            start = s.indexOf('\u0001', from);
        }
        b.append(s, from, s.length());
        return b;
    }

    private ArrayAdapter<String> listAdapter(int layout) {
        return new ArrayAdapter<String>(this, layout, new ArrayList<String>()) {
            @Override
            public View getView(int position, View convertView, ViewGroup parent) {
                return compactRow(super.getView(position, convertView, parent));
            }

            @Override
            public View getDropDownView(int position, View convertView, ViewGroup parent) {
                return compactRow(super.getDropDownView(position, convertView, parent));
            }
        };
    }

    public void listInit(View v) {
        if (v instanceof Spinner) {
            ArrayAdapter<String> a = listAdapter(android.R.layout.simple_spinner_item);
            a.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
            final Spinner s = (Spinner) v;
            s.setAdapter(a);
            s.setOnItemSelectedListener(this);
            // The list of the Spinner is a popup of its own: the one of the Spinner is over it (overlapAnchor of the
            // Material theme) or far under it while the soft keyboard is shown; this one is under the Spinner like the
            // list of a ComboBox of Windows
            s.setOnTouchListener(new View.OnTouchListener() {
                @Override
                public boolean onTouch(View view, android.view.MotionEvent e) {
                    if (!s.isEnabled()) return false;
                    if (e.getAction() == android.view.MotionEvent.ACTION_UP
                            && e.getX() >= 0 && e.getY() >= 0 && e.getX() < s.getWidth() && e.getY() < s.getHeight()) {
                        spinnerPopup(s);
                    }
                    return true;
                }
            });
        } else if (v instanceof ListView) {
            ListView lv = (ListView) v;
            lv.setAdapter(listAdapter(android.R.layout.simple_list_item_single_choice));
            lv.setChoiceMode(ListView.CHOICE_MODE_SINGLE);
            lv.setOnItemClickListener(this);
        }
    }

    // The list of a Spinner under it (the touch listener of listInit): the rows of its adapter, a choice is the one of
    // the Spinner (onItemSelected). It is a view over the content of the activity, not a popup window: the content is
    // moved up while the soft keyboard is shown (adjustPan) and a popup window was far under the Spinner then.
    // A touch out of the list closes it. The content is the one of the window of the Spinner (a form in its own
    // activity, FormActivity: the list was in this activity behind it)
    private void spinnerPopup(final Spinner s) {
        final android.widget.SpinnerAdapter items = s.getAdapter();
        ViewGroup windowContent = s.getRootView().findViewById(android.R.id.content);
        // a Spinner of a form of ShowModal (over the content in its layout, formAttachTop): the list is in that layout
        for (android.view.ViewParent p = s.getParent(); p instanceof ViewGroup; p = p.getParent()) {
            if ("mffTopHost".equals(((ViewGroup) p).getTag())) {
                windowContent = (ViewGroup) p;
                break;
            }
        }
        final ViewGroup content = windowContent != null ? windowContent : (ViewGroup) findViewById(android.R.id.content);
        if (items == null || items.getCount() == 0 || content == null) return;
        final android.widget.FrameLayout overlay = new android.widget.FrameLayout(this);
        // Back and the hidden form close it (closeSpinnerPopup)
        overlay.setTag("mffSpinnerPopup");
        final ListView list = new ListView(this);
        list.setDivider(null);
        list.setChoiceMode(ListView.CHOICE_MODE_SINGLE);
        GradientDrawable back = new GradientDrawable();
        back.setColor(night(Color.WHITE, 0xFF252526));
        back.setStroke(Math.max(1, dp(1) / 2), 0xFF7A7A7A);
        list.setBackground(back);
        list.setPadding(1, 1, 1, 1);
        if (Build.VERSION.SDK_INT >= 21) list.setElevation(dp(4));
        list.setAdapter(new android.widget.BaseAdapter() {
            @Override
            public int getCount() {
                return items.getCount();
            }

            @Override
            public Object getItem(int position) {
                return items.getItem(position);
            }

            @Override
            public long getItemId(int position) {
                return position;
            }

            @Override
            public View getView(int position, View convertView, ViewGroup parent) {
                View v = items.getDropDownView(position, convertView, parent);
                // the chosen item like the selected one of a list of Windows
                v.setBackgroundColor(position == s.getSelectedItemPosition() ? night(0xFFCCE4F7, 0xFF094771) : Color.TRANSPARENT);
                return v;
            }
        });
        list.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                content.removeView(overlay);
                if (s.getSelectedItemPosition() == position) {
                    onListChange(s, position);
                } else {
                    // onItemSelected gives the choice to the native side
                    programSelections.remove(s);
                    s.setSelection(position);
                }
            }
        });
        overlay.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View view, android.view.MotionEvent e) {
                if (e.getAction() == android.view.MotionEvent.ACTION_DOWN) content.removeView(overlay);
                return true;
            }
        });
        // the place of the Spinner in the content: the list is under it, over it when there is more place there
        int[] at = new int[2], origin = new int[2];
        s.getLocationInWindow(at);
        content.getLocationInWindow(origin);
        int x = at[0] - origin[0], top = at[1] - origin[1], bottom = top + s.getHeight();
        list.measure(View.MeasureSpec.makeMeasureSpec(s.getWidth(), View.MeasureSpec.EXACTLY), View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED));
        int rows = Math.min(items.getCount(), 12);
        int rowHeight = items.getCount() > 0 ? measureRow(items, list) : dp(24);
        int wanted = rows * rowHeight + 2;
        int below = content.getHeight() - bottom, above = top;
        android.widget.FrameLayout.LayoutParams lp;
        if (wanted <= below || below >= above) {
            lp = new android.widget.FrameLayout.LayoutParams(s.getWidth(), Math.min(wanted, below));
            lp.topMargin = bottom;
        } else {
            lp = new android.widget.FrameLayout.LayoutParams(s.getWidth(), Math.min(wanted, above));
            lp.topMargin = top - lp.height;
        }
        lp.leftMargin = x;
        overlay.addView(list, lp);
        content.addView(overlay, new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
        int selected = s.getSelectedItemPosition();
        if (selected >= 0) list.setSelection(selected);
    }

    // The open list of a Spinner in v (a window, a form) is closed; false - there was none
    private static boolean closeSpinnerPopup(View v) {
        View popup = v == null ? null : v.findViewWithTag("mffSpinnerPopup");
        if (popup == null || !(popup.getParent() instanceof ViewGroup)) return false;
        ((ViewGroup) popup.getParent()).removeView(popup);
        return true;
    }

    // The height of a row of the list of a Spinner (its first item)
    private static int measureRow(android.widget.SpinnerAdapter items, ViewGroup parent) {
        View row = items.getDropDownView(0, null, parent);
        row.measure(View.MeasureSpec.makeMeasureSpec(Math.max(1, parent.getMeasuredWidth()), View.MeasureSpec.AT_MOST), View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED));
        return Math.max(1, row.getMeasuredHeight());
    }

    // ComboBoxEdit.ShowDropDown: the list of a Spinner takes the focus (the keys of the IntelliSense of the IDE go to
    // the editor) and can not be opened by the program: a list with the items of the Spinner is shown in its place
    // (like a <select> of the Web with a size). A tap on an item is the choice of the Spinner (onListChange)
    private final HashMap<Spinner, ListView> spinnerLists = new HashMap<>();

    public void listShowDropDown(View v, boolean show) {
        if (!(v instanceof Spinner)) return;
        final Spinner s = (Spinner) v;
        ListView list = spinnerLists.get(s);
        if (!show) {
            if (list != null) {
                list.setVisibility(View.GONE);
                s.setVisibility(View.VISIBLE);
            }
            return;
        }
        if (list == null) {
            if (!(s.getParent() instanceof ViewGroup) || s.getAdapter() == null) return;
            list = spinnerList(s);
            spinnerLists.put(s, list);
        }
        int index = s.getSelectedItemPosition();
        if (index >= 0 && index < s.getCount()) {
            list.setItemChecked(index, true);
            list.setSelection(index);
        } else {
            list.clearChoices();
        }
        list.setVisibility(View.VISIBLE);
        s.setVisibility(View.INVISIBLE);
    }

    private ListView spinnerList(final Spinner s) {
        final ListView list = new ListView(this);
        final android.widget.SpinnerAdapter items = s.getAdapter();
        list.setBackgroundColor(night(Color.WHITE, 0xFF252526));
        list.setChoiceMode(ListView.CHOICE_MODE_SINGLE);
        list.setDivider(null);
        list.setFocusable(false);
        final android.widget.BaseAdapter rows = new android.widget.BaseAdapter() {
            @Override
            public int getCount() {
                return items.getCount();
            }

            @Override
            public Object getItem(int position) {
                return items.getItem(position);
            }

            @Override
            public long getItemId(int position) {
                return position;
            }

            @Override
            public View getView(int position, View convertView, ViewGroup parent) {
                TextView t = convertView instanceof TextView ? (TextView) convertView : null;
                if (t == null) {
                    t = defaultText(new TextView(mffActivity.this));
                    t.setSingleLine(true);
                    t.setEllipsize(android.text.TextUtils.TruncateAt.END);
                    t.setPadding(dp(4), dp(1), dp(4), dp(1));
                    // the chosen row (setItemChecked: activated) is like the selected item of a list of Windows
                    android.graphics.drawable.StateListDrawable back = new android.graphics.drawable.StateListDrawable();
                    back.addState(new int[]{android.R.attr.state_activated}, new android.graphics.drawable.ColorDrawable(0xFF0078D7));
                    back.addState(new int[]{}, new android.graphics.drawable.ColorDrawable(Color.TRANSPARENT));
                    t.setBackground(back);
                    t.setTextColor(new android.content.res.ColorStateList(
                            new int[][]{{android.R.attr.state_activated}, {}}, new int[]{Color.WHITE, textColor()}));
                }
                Object item = items.getItem(position);
                t.setText(textWithPictures(item == null ? "" : item.toString(), t.getTextSize()));
                return t;
            }
        };
        list.setAdapter(rows);
        items.registerDataSetObserver(new android.database.DataSetObserver() {
            @Override
            public void onChanged() {
                rows.notifyDataSetChanged();
            }

            @Override
            public void onInvalidated() {
                rows.notifyDataSetInvalidated();
            }
        });
        list.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                spinnerSetIndex(s, position);
                onListChange(s, position);
            }
        });
        ViewGroup g = (ViewGroup) s.getParent();
        g.addView(list, g.indexOfChild(s) + 1, spinnerListParams(s));
        // the list follows the place of the Spinner (SetBounds of the ComboBoxEdit)
        s.addOnLayoutChangeListener(new View.OnLayoutChangeListener() {
            @Override
            public void onLayoutChange(View view, int l, int t, int r, int b, int ol, int ot, int or, int ob) {
                final ViewGroup.LayoutParams lp = spinnerListParams(s);
                ViewGroup.LayoutParams cur = list.getLayoutParams();
                if (!(cur instanceof AbsoluteLayout.LayoutParams) || !(lp instanceof AbsoluteLayout.LayoutParams)
                        || cur.width != lp.width || cur.height != lp.height
                        || ((AbsoluteLayout.LayoutParams) cur).x != ((AbsoluteLayout.LayoutParams) lp).x
                        || ((AbsoluteLayout.LayoutParams) cur).y != ((AbsoluteLayout.LayoutParams) lp).y) {
                    list.post(new Runnable() {
                        @Override
                        public void run() {
                            list.setLayoutParams(lp);
                        }
                    });
                }
            }
        });
        return list;
    }

    // The text of a CheckBox, a RadioButton or a Label has the lines which its height shows, the end of a longer one is
    // "..." (a line was cut in the middle: the texts of Android are wider than the ones of Windows)
    private static final java.util.Set<View> fitLinesViews = java.util.Collections.newSetFromMap(new java.util.WeakHashMap<View, Boolean>());

    private static View fitLines(final View v) {
        if (!(v instanceof TextView)) return v;
        final TextView t = (TextView) v;
        t.setEllipsize(android.text.TextUtils.TruncateAt.END);
        if (!fitLinesViews.add(v)) {
            t.requestLayout();
            return v;
        }
        t.addOnLayoutChangeListener(new View.OnLayoutChangeListener() {
            @Override
            public void onLayoutChange(View view, int l, int top, int r, int b, int ol, int ot, int or, int ob) {
                int line = t.getLineHeight();
                if (line <= 0) return;
                final int lines = Math.max(1, (b - top - t.getPaddingTop() - t.getPaddingBottom()) / line);
                if (lines == t.getMaxLines()) return;
                t.post(new Runnable() {
                    @Override
                    public void run() {
                        t.setMaxLines(lines);
                    }
                });
            }
        });
        return v;
    }

    private static ViewGroup.LayoutParams spinnerListParams(Spinner s) {
        ViewGroup.LayoutParams lp = s.getLayoutParams();
        if (lp instanceof AbsoluteLayout.LayoutParams) {
            AbsoluteLayout.LayoutParams a = (AbsoluteLayout.LayoutParams) lp;
            return new AbsoluteLayout.LayoutParams(a.width, a.height, a.x, a.y);
        }
        return new AbsoluteLayout.LayoutParams(lp == null ? ViewGroup.LayoutParams.MATCH_PARENT : lp.width,
                lp == null ? ViewGroup.LayoutParams.MATCH_PARENT : lp.height, 0, 0);
    }

    // The selection which the program makes is not a choice of the user (like CB_SETCURSEL of Windows and the
    // selectedIndex of a <select>): its onItemSelected does not go to the native side
    private final HashMap<View, Integer> programSelections = new HashMap<>();

    private void spinnerSetIndex(Spinner s, int index) {
        if (index < 0 || index >= s.getCount()) return;
        if (s.getSelectedItemPosition() != index) {
            programSelections.put(s, index);
            s.setSelection(index);
        }
        ListView list = spinnerLists.get(s);
        if (list != null) {
            list.setItemChecked(index, true);
            if (index < list.getFirstVisiblePosition() || index > list.getLastVisiblePosition()) list.setSelection(index);
        }
    }

    // index < 0 appends
    public void listInsert(View v, int index, String text) {
        ArrayAdapter<String> a = adapterOf(v);
        if (a == null) return;
        if (index < 0 || index > a.getCount()) a.add(text); else a.insert(text, index);
    }

    public void listSet(View v, int index, String text) {
        ArrayAdapter<String> a = adapterOf(v);
        if (a == null || index < 0 || index >= a.getCount()) return;
        ArrayList<String> items = itemsOf(a);
        items.set(index, text);
        a.setNotifyOnChange(false);
        a.clear();
        a.addAll(items);
        a.notifyDataSetChanged();
    }

    // ArrayAdapter.remove(item) removes the first equal item: the lists are rebuilt to work by index
    private static ArrayList<String> itemsOf(ArrayAdapter<String> a) {
        ArrayList<String> items = new ArrayList<>();
        for (int i = 0; i < a.getCount(); i++) items.add(a.getItem(i));
        return items;
    }

    public void listRemove(View v, int index) {
        ArrayAdapter<String> a = adapterOf(v);
        if (a == null || index < 0 || index >= a.getCount()) return;
        ArrayList<String> items = itemsOf(a);
        items.remove(index);
        a.setNotifyOnChange(false);
        a.clear();
        a.addAll(items);
        a.notifyDataSetChanged();
    }

    public void listClear(View v) {
        ArrayAdapter<String> a = adapterOf(v);
        if (a != null) a.clear();
    }

    public int listGetIndex(View v) {
        if (v instanceof Spinner) return ((Spinner) v).getSelectedItemPosition();
        if (v instanceof AbsListView) {
            int position = ((AbsListView) v).getCheckedItemPosition();
            return position < 0 ? position : position - headerRows(v);
        }
        return -1;
    }

    public void listSetIndex(View v, int index) {
        if (v instanceof Spinner) {
            if (index >= 0) {
                spinnerSetIndex((Spinner) v, index);
            } else {
                ListView list = spinnerLists.get(v);
                if (list != null) list.clearChoices();
            }
        } else if (v instanceof AbsListView) {
            AbsListView lv = (AbsListView) v;
            if (index < 0) lv.clearChoices(); else lv.setItemChecked(index + headerRows(lv), true);
        }
    }

    // GroupBox: an AbsoluteLayout with a border and a caption
    public void groupSetTitle(View v, String title) {
        if (!(v instanceof ViewGroup)) return;
        ViewGroup g = (ViewGroup) v;
        TextView caption = g.findViewWithTag("mffGroupCaption");
        if (caption == null) {
            float dp = TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 1, getResources().getDisplayMetrics());
            GradientDrawable border = new GradientDrawable();
            border.setStroke(Math.max(1, (int) dp), Color.GRAY);
            border.setCornerRadius(4 * dp);
            g.setBackground(border);
            caption = new TextView(this);
            caption.setTag("mffGroupCaption");
            caption.setPadding((int) (6 * dp), 0, (int) (6 * dp), 0);
            g.addView(caption, new AbsoluteLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT, (int) (8 * dp), 0));
        }
        caption.setText(title);
    }

    // Font of the controls (My.Sys.Drawing.Font): an empty name and a size <= 0 keep the ones of Android
    // Label without WordWraps: one line, "..." at the end of a text which does not fit
    public void textSetSingleLine(View v, boolean singleLine) {
        if (!(v instanceof TextView)) return;
        TextView t = (TextView) v;
        t.setSingleLine(singleLine);
        if (singleLine) t.setEllipsize(android.text.TextUtils.TruncateAt.END);
        // the lines which the height of the label shows, "..." at the end of a longer text (fitLines)
        else fitLines(t);
    }

    // v is the handle of any control (the one of a Form is the activity)
    public void textSetFont(Object v, String name, double size, int bold, int italic, int underline, int strikeOut) {
        if (!(v instanceof TextView)) return;
        TextView t = (TextView) v;
        if (size > 0) t.setTextSize(TypedValue.COMPLEX_UNIT_PX, (float) size);
        android.graphics.Typeface current = t.getTypeface();
        int style = (bold != 0 ? android.graphics.Typeface.BOLD : 0) | (italic != 0 ? android.graphics.Typeface.ITALIC : 0);
        if ((name != null && !name.isEmpty()) || style != (current == null ? 0 : current.getStyle())) {
            android.graphics.Typeface family = name == null || name.isEmpty() ? current : fontFamily(name);
            t.setTypeface(android.graphics.Typeface.create(family, style));
        }
        int flags = t.getPaintFlags() & ~(android.graphics.Paint.UNDERLINE_TEXT_FLAG | android.graphics.Paint.STRIKE_THRU_TEXT_FLAG);
        if (underline != 0) flags |= android.graphics.Paint.UNDERLINE_TEXT_FLAG;
        if (strikeOut != 0) flags |= android.graphics.Paint.STRIKE_THRU_TEXT_FLAG;
        t.setPaintFlags(flags);
    }

    private int dp(float value) {
        return (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, value, getResources().getDisplayMetrics());
    }

    // A CommandButton has its bounds like on Windows (23 - 25 units high in the forms): the Material button has insets of
    // 6dp above and under it, its minimum height and its padding, only a strip without the text was seen in them
    private View compactButton(View v) {
        if (!(v instanceof TextView)) return v;
        TextView b = (TextView) v;
        // A newer Material library (1.3 and later): the background of the Material button 1dp inside its bounds like a
        // button of Windows
        boolean insets = true;
        for (String inset : new String[]{"setInsetTop", "setInsetBottom"}) {
            try {
                b.getClass().getMethod(inset, int.class).invoke(b, dp(1));
            } catch (Exception ex) {
                insets = false;
            }
        }
        if (!insets) compactButtonBackground(b);
        b.setMinHeight(0);
        b.setMinimumHeight(0);
        b.setMinWidth(0);
        b.setMinimumWidth(0);
        b.setPadding(dp(8), 0, dp(8), 0);
        b.setGravity(Gravity.CENTER);
        return b;
    }

    // The circle of a RadioButton and the box of a CheckBox (24dp) in a lower control (16 - 21 units like on Windows) were
    // cut: the picture becomes as high as the control
    private View fitButtonDrawable(final View v) {
        if (!(v instanceof android.widget.CompoundButton)) return v;
        final android.widget.CompoundButton b = (android.widget.CompoundButton) v;
        final android.graphics.drawable.Drawable original = androidx.core.widget.CompoundButtonCompat.getButtonDrawable(b);
        if (original == null || original.getIntrinsicHeight() <= 0) return v;
        b.addOnLayoutChangeListener(new View.OnLayoutChangeListener() {
            @Override
            public void onLayoutChange(View view, int l, int t, int r, int bottom, int ol, int ot, int or, int ob) {
                int size = Math.min(original.getIntrinsicHeight(), bottom - t);
                android.graphics.drawable.Drawable current = androidx.core.widget.CompoundButtonCompat.getButtonDrawable(b);
                int now = current == null ? -1 : current.getIntrinsicHeight();
                if (size <= 0 || size == now) return;
                final android.graphics.drawable.Drawable picture = size >= original.getIntrinsicHeight() ? original : new FitDrawable(original, size);
                b.post(new Runnable() {
                    @Override
                    public void run() {
                        b.setButtonDrawable(picture);
                    }
                });
            }
        });
        return v;
    }

    // A picture drawn in a smaller square (its state and its animations are the ones of the picture)
    private static class FitDrawable extends android.graphics.drawable.Drawable implements android.graphics.drawable.Drawable.Callback {
        private final android.graphics.drawable.Drawable picture;
        private final int size;

        FitDrawable(android.graphics.drawable.Drawable picture, int size) {
            this.picture = picture;
            this.size = size;
            picture.setCallback(this);
        }

        @Override
        public int getIntrinsicWidth() {
            return size;
        }

        @Override
        public int getIntrinsicHeight() {
            return size;
        }

        @Override
        protected void onBoundsChange(android.graphics.Rect bounds) {
            picture.setBounds(bounds);
        }

        @Override
        public void draw(android.graphics.Canvas canvas) {
            picture.draw(canvas);
        }

        @Override
        public boolean isStateful() {
            return picture.isStateful();
        }

        @Override
        protected boolean onStateChange(int[] state) {
            boolean changed = picture.setState(state);
            invalidateSelf();
            return changed;
        }

        @Override
        public void jumpToCurrentState() {
            picture.jumpToCurrentState();
        }

        @Override
        public void setTintList(android.content.res.ColorStateList tint) {
            androidx.core.graphics.drawable.DrawableCompat.setTintList(picture, tint);
        }

        @Override
        public void setTintMode(android.graphics.PorterDuff.Mode mode) {
            androidx.core.graphics.drawable.DrawableCompat.setTintMode(picture, mode);
        }

        @Override
        public void setAlpha(int alpha) {
            picture.setAlpha(alpha);
        }

        @Override
        public void setColorFilter(android.graphics.ColorFilter filter) {
            picture.setColorFilter(filter);
        }

        @Override
        public int getOpacity() {
            return picture.getOpacity();
        }

        @Override
        public void invalidateDrawable(android.graphics.drawable.Drawable who) {
            invalidateSelf();
        }

        @Override
        public void scheduleDrawable(android.graphics.drawable.Drawable who, Runnable what, long when) {
            scheduleSelf(what, when);
        }

        @Override
        public void unscheduleDrawable(android.graphics.drawable.Drawable who, Runnable what) {
            unscheduleSelf(what);
        }
    }

    // Material 1.2 (no setInsetTop) or the AppCompat button: the background of the button is drawn here without the insets
    // of 6dp, the color of the theme (and the one of a disabled button) with the ripple, 1dp inside its bounds like a
    // button of Windows (the buttons next to each other have a gap of 2dp)
    private void compactButtonBackground(TextView b) {
        android.content.res.ColorStateList tint = b.getBackgroundTintList();
        if (tint == null) {
            TypedValue primary = new TypedValue();
            getTheme().resolveAttribute(androidx.appcompat.R.attr.colorPrimary, primary, true);
            tint = android.content.res.ColorStateList.valueOf(primary.data);
        }
        GradientDrawable shape = new GradientDrawable();
        shape.setCornerRadius(dp(4));
        shape.setColor(tint);
        android.graphics.drawable.Drawable inset = new android.graphics.drawable.InsetDrawable(shape, dp(1));
        b.setBackgroundTintList(null);
        b.setBackground(new android.graphics.drawable.RippleDrawable(android.content.res.ColorStateList.valueOf(0x40FFFFFF), inset, null));
    }

    /**
     * Creates the widgets which need more than the (Context) constructor (or a listener).
     * Used by the controls whose ClassAncestor is "mff:&lt;kind&gt;" on the FreeBasic side.
     */
    public View createView(String kind) {
        switch (kind) {
            // CommandButton, CheckBox, RadioButton: the Material widgets with a MaterialComponents theme, else the AppCompat ones
            case "Button": {
                View b = materialView("com.google.android.material.button.MaterialButton");
                return compactButton(b != null ? b : new androidx.appcompat.widget.AppCompatButton(this));
            }
            case "CheckBox": {
                View c = materialView("com.google.android.material.checkbox.MaterialCheckBox");
                return fitLines(fitButtonDrawable(c != null ? c : new androidx.appcompat.widget.AppCompatCheckBox(this)));
            }
            case "RadioButton": {
                View r = materialView("com.google.android.material.radiobutton.MaterialRadioButton");
                return fitLines(fitButtonDrawable(r != null ? r : new androidx.appcompat.widget.AppCompatRadioButton(this)));
            }
            case "ProgressBar": {
                ProgressBar p = new ProgressBar(this, null, android.R.attr.progressBarStyleHorizontal);
                p.setIndeterminate(false);
                return p;
            }
            case "SeekBar": {
                SeekBar s = new SeekBar(this);
                s.setOnSeekBarChangeListener(this);
                return s;
            }
            // UpDown, NumericUpDown: the number with the arrows like the ones of Windows (a NumberPicker is a wheel of
            // three rows, its numbers were one over the other in the height of a text box)
            case "NumberPicker":
                return new MffSpinBox(this);
            case "DatePicker": {
                final DatePicker d = new DatePicker(this);
                if (Build.VERSION.SDK_INT >= 11) d.setCalendarViewShown(false);
                d.init(d.getYear(), d.getMonth(), d.getDayOfMonth(), new DatePicker.OnDateChangedListener() {
                    @Override
                    public void onDateChanged(DatePicker view, int year, int month, int day) {
                        onListChange(view, year * 10000 + (month + 1) * 100 + day);
                    }
                });
                return d;
            }
            case "CalendarView": {
                android.widget.CalendarView c = new android.widget.CalendarView(this);
                c.setOnDateChangeListener(new android.widget.CalendarView.OnDateChangeListener() {
                    @Override
                    public void onSelectedDayChange(android.widget.CalendarView view, int year, int month, int day) {
                        java.util.Calendar cal = java.util.Calendar.getInstance();
                        cal.set(year, month, day, 0, 0, 0);
                        view.setDate(cal.getTimeInMillis(), false, false);
                        onListChange(view, year * 10000 + (month + 1) * 100 + day);
                    }
                });
                return c;
            }
            case "WebView": {
                WebView w = new WebView(this);
                w.setWebViewClient(new WebViewClient());
                w.getSettings().setJavaScriptEnabled(true);
                return w;
            }
            case "Link": {
                TextView t = new TextView(this);
                // the text of the theme like a SysLink of Windows, the links blue (light blue in the night mode)
                t.setTextColor(textColor());
                t.setLinkTextColor(night(Color.BLUE, 0xFF4DAAFC));
                t.setMovementMethod(LinkMovementMethod.getInstance());
                return t;
            }
            case "ImageView":
                return new ImageView(this);
            // ScrollControl
            case "ScrollLayout":
                return new MffScrollLayout(this);
            // OpenFileControl: the file list like the one of the Web (fileViewFill)
            case "FileView":
                return new MffFileView(this);
            // ListView of View vsIcon: the items are cells with the picture above the text (tableAdapter, iconCell)
            case "IconGrid": {
                android.widget.GridView g = new android.widget.GridView(this);
                g.setNumColumns(android.widget.GridView.AUTO_FIT);
                g.setColumnWidth(dp(96));
                g.setStretchMode(android.widget.GridView.STRETCH_SPACING_UNIFORM);
                g.setVerticalSpacing(dp(4));
                g.setPadding(dp(4), dp(4), dp(4), dp(4));
                g.setClipToPadding(false);
                return g;
            }
            case "Layout":
            default:
                return new MffLayout(this);
        }
    }

    // A widget of the Material library, null if the library or a MaterialComponents theme is missing
    private View materialView(String className) {
        try {
            return (View) Class.forName(className).getConstructor(Context.class).newInstance(this);
        } catch (Throwable e) {
            return null;
        }
    }

    // ---- Canvas (My.Sys.Drawing.Canvas) --------------------------------------------------------
    // The containers of the controls are MffLayouts: they keep a bitmap of the size of the view in which
    // the FreeBasic side draws (also outside of a paint); the children are drawn over it.
    // A new size asks the native side to paint again (onPaint).
    public static class MffLayout extends AbsoluteLayout {
        android.graphics.Bitmap bitmap;
        android.graphics.Canvas canvas;
        final android.graphics.Path path = new android.graphics.Path();
        // The view takes the text of the soft keyboard (setKeyEvent): the characters go to onViewKey
        boolean textInput;

        public MffLayout(Context context) {
            super(context);
            setWillNotDraw(false);
        }

        @Override
        public boolean onCheckIsTextEditor() {
            return textInput;
        }

        @Override
        public android.view.inputmethod.InputConnection onCreateInputConnection(android.view.inputmethod.EditorInfo outAttrs) {
            if (!textInput || !(getContext() instanceof mffActivity)) return null;
            final mffActivity activity = (mffActivity) getContext();
            outAttrs.inputType = android.text.InputType.TYPE_CLASS_TEXT | android.text.InputType.TYPE_TEXT_FLAG_MULTI_LINE | android.text.InputType.TYPE_TEXT_FLAG_NO_SUGGESTIONS;
            outAttrs.imeOptions = android.view.inputmethod.EditorInfo.IME_FLAG_NO_EXTRACT_UI | android.view.inputmethod.EditorInfo.IME_FLAG_NO_FULLSCREEN;
            return new android.view.inputmethod.BaseInputConnection(this, false) {
                // The composing text already sent to the view: the keyboards (Gboard, also with the keys of a hardware
                // keyboard) give the letters as a composing text, it is replaced by the next one or by the committed text
                String composing = "";

                void sendText(String s) {
                    for (int i = 0; i < s.length(); ) {
                        int c = s.codePointAt(i);
                        if (c == '\n') activity.sendViewVirtualKey(MffLayout.this, 13);
                        else activity.onViewKey(MffLayout.this, 2, c, 0);
                        i += Character.charCount(c);
                    }
                }

                // Only the part of the composing text which changed is deleted (Backspace) and sent again
                void replaceComposing(String s) {
                    int same = 0;
                    while (same < composing.length() && same < s.length() && composing.charAt(same) == s.charAt(same)) same++;
                    if (same > 0 && Character.isHighSurrogate(composing.charAt(same - 1))) same--;
                    for (int i = composing.codePointCount(same, composing.length()); i > 0; i--) activity.sendViewVirtualKey(MffLayout.this, 8);
                    sendText(s.substring(same));
                    composing = s;
                }

                @Override
                public boolean setComposingText(CharSequence text, int newCursorPosition) {
                    replaceComposing(text.toString());
                    return true;
                }

                @Override
                public boolean finishComposingText() {
                    composing = "";
                    return true;
                }

                @Override
                public boolean commitText(CharSequence text, int newCursorPosition) {
                    replaceComposing(text.toString());
                    composing = "";
                    return true;
                }

                @Override
                public boolean deleteSurroundingText(int beforeLength, int afterLength) {
                    for (int i = 0; i < beforeLength; i++) activity.sendViewVirtualKey(MffLayout.this, 8);
                    for (int i = 0; i < afterLength; i++) activity.sendViewVirtualKey(MffLayout.this, 46);
                    return true;
                }

                @Override
                public boolean sendKeyEvent(android.view.KeyEvent e) {
                    return activity.sendViewKey(MffLayout.this, e);
                }
            };
        }

        @Override
        protected void onSizeChanged(int w, int h, int oldw, int oldh) {
            super.onSizeChanged(w, h, oldw, oldh);
            if (w > 0 && h > 0) {
                bitmap = android.graphics.Bitmap.createBitmap(w, h, android.graphics.Bitmap.Config.ARGB_8888);
                canvas = new android.graphics.Canvas(bitmap);
            } else {
                bitmap = null;
                canvas = null;
            }
            if (getContext() instanceof mffActivity) ((mffActivity) getContext()).canvasRepaint(this);
        }

        @Override
        protected void onDraw(android.graphics.Canvas c) {
            super.onDraw(c);
            if (bitmap != null) c.drawBitmap(bitmap, 0, 0, null);
        }
    }

    // ScrollControl: its children are scrolled when they are below or to the right of it (the scroll bars of Windows). A
    // drag (also one which begins on a child), the mouse wheel and the scroll bars; the rest of a drag at the end goes to
    // the scrolled view around it (FormActivity: nested scrolling)
    public static class MffScrollLayout extends MffLayout {
        private final int touchSlop;
        private float lastX, lastY, downX, downY;
        private boolean dragging;

        public MffScrollLayout(Context context) {
            super(context);
            touchSlop = android.view.ViewConfiguration.get(context).getScaledTouchSlop();
            setVerticalScrollBarEnabled(true);
            setHorizontalScrollBarEnabled(true);
            if (Build.VERSION.SDK_INT >= 21) setNestedScrollingEnabled(true);
        }

        private int contentWidth() {
            int w = 0;
            for (int i = 0; i < getChildCount(); i++) {
                View c = getChildAt(i);
                if (c.getVisibility() != View.GONE) w = Math.max(w, c.getRight());
            }
            return w;
        }

        private int contentHeight() {
            int h = 0;
            for (int i = 0; i < getChildCount(); i++) {
                View c = getChildAt(i);
                if (c.getVisibility() != View.GONE) h = Math.max(h, c.getBottom());
            }
            return h;
        }

        private int maxScrollX() {
            return Math.max(0, contentWidth() - getWidth());
        }

        private int maxScrollY() {
            return Math.max(0, contentHeight() - getHeight());
        }

        // Scrolls by dx, dy (the parts which can be scrolled); returns the part of dy which was scrolled
        private int scrollWithin(int dx, int dy) {
            int x = Math.max(0, Math.min(maxScrollX(), getScrollX() + dx));
            int y = Math.max(0, Math.min(maxScrollY(), getScrollY() + dy));
            int scrolledY = y - getScrollY();
            if (x != getScrollX() || y != getScrollY()) {
                scrollTo(x, y);
                awakenScrollBars();
            }
            return scrolledY;
        }

        @Override
        protected void onLayout(boolean changed, int l, int t, int r, int b) {
            super.onLayout(changed, l, t, r, b);
            // the children were moved or the view became larger: the scroll position stays in the content
            if (getScrollX() > maxScrollX() || getScrollY() > maxScrollY()) scrollTo(Math.min(getScrollX(), maxScrollX()), Math.min(getScrollY(), maxScrollY()));
        }

        @Override
        protected int computeVerticalScrollRange() {
            return Math.max(getHeight(), contentHeight());
        }

        @Override
        protected int computeHorizontalScrollRange() {
            return Math.max(getWidth(), contentWidth());
        }

        @Override
        public boolean onInterceptTouchEvent(android.view.MotionEvent e) {
            switch (e.getActionMasked()) {
                case android.view.MotionEvent.ACTION_DOWN:
                    downX = lastX = e.getX();
                    downY = lastY = e.getY();
                    dragging = false;
                    if (Build.VERSION.SDK_INT >= 21 && maxScrollY() > 0) startNestedScroll(View.SCROLL_AXIS_VERTICAL);
                    break;
                case android.view.MotionEvent.ACTION_MOVE:
                    if (!dragging && (maxScrollX() > 0 || maxScrollY() > 0)
                            && (Math.abs(e.getY() - downY) > touchSlop || Math.abs(e.getX() - downX) > touchSlop)) {
                        dragging = true;
                        lastX = e.getX();
                        lastY = e.getY();
                        return true;
                    }
                    break;
            }
            return false;
        }

        @Override
        public boolean onTouchEvent(android.view.MotionEvent e) {
            switch (e.getActionMasked()) {
                case android.view.MotionEvent.ACTION_DOWN:
                    downX = lastX = e.getX();
                    downY = lastY = e.getY();
                    dragging = false;
                    if (Build.VERSION.SDK_INT >= 21 && maxScrollY() > 0) startNestedScroll(View.SCROLL_AXIS_VERTICAL);
                    super.onTouchEvent(e);
                    // the moves of a drag on the empty place come here too
                    return maxScrollX() > 0 || maxScrollY() > 0 || isClickable();
                case android.view.MotionEvent.ACTION_MOVE: {
                    if (!dragging) {
                        if (Math.abs(e.getY() - downY) <= touchSlop && Math.abs(e.getX() - downX) <= touchSlop) return super.onTouchEvent(e);
                        dragging = true;
                        // not a click of the view any more
                        android.view.MotionEvent cancel = android.view.MotionEvent.obtain(e);
                        cancel.setAction(android.view.MotionEvent.ACTION_CANCEL);
                        super.onTouchEvent(cancel);
                        cancel.recycle();
                    }
                    int dx = Math.round(lastX - e.getX()), dy = Math.round(lastY - e.getY());
                    lastX = e.getX();
                    lastY = e.getY();
                    int scrolled = scrollWithin(dx, dy);
                    // the rest of the drag (this view is at its end) scrolls the view around it
                    if (Build.VERSION.SDK_INT >= 21 && dy != scrolled) dispatchNestedScroll(0, scrolled, 0, dy - scrolled, null);
                    return true;
                }
                case android.view.MotionEvent.ACTION_UP:
                case android.view.MotionEvent.ACTION_CANCEL: {
                    boolean wasDragging = dragging;
                    dragging = false;
                    if (Build.VERSION.SDK_INT >= 21) stopNestedScroll();
                    return wasDragging || super.onTouchEvent(e);
                }
            }
            return super.onTouchEvent(e);
        }

        // The mouse wheel: the rest goes to the view around it (onGenericMotionEvent of its parent)
        @Override
        public boolean onGenericMotionEvent(android.view.MotionEvent e) {
            if ((e.getSource() & android.view.InputDevice.SOURCE_CLASS_POINTER) != 0 && e.getAction() == android.view.MotionEvent.ACTION_SCROLL) {
                float v = e.getAxisValue(android.view.MotionEvent.AXIS_VSCROLL), h = e.getAxisValue(android.view.MotionEvent.AXIS_HSCROLL);
                int step = Math.round(48 * getResources().getDisplayMetrics().density);
                int dy = Math.round(-v * step), dx = Math.round(h * step);
                if (scrollWithin(dx, dy) != 0 || (dx != 0 && maxScrollX() > 0)) return true;
            }
            return super.onGenericMotionEvent(e);
        }
    }

    // ---- OpenFileControl: the folders and the files of a folder like the file list of the Web (FileViewFill of
    // mff_lib.js): the buttons of the views "Large icons" and "List" above it (the view is remembered), the pictures of
    // the folders and the files. A tap on a folder opens it, a tap on a file chooses it, a double tap activates it. The
    // changes are onListChange of the view, fileViewState gives them to the native side
    public static class MffFileView extends LinearLayout {
        private final mffActivity activity;
        private final ListView list;
        private final android.widget.GridView grid;
        private final ImageButton iconButton, listButton;
        private final android.widget.EditText path;
        private final ArrayList<String> names = new ArrayList<>();
        private final BaseAdapter adapter;
        private int dirs;
        private String dir = "/", state = "";
        private java.util.regex.Pattern accept;
        private boolean multiple;
        private int lastTap = -1;
        private long lastTapTime;

        public MffFileView(final mffActivity activity) {
            super(activity);
            this.activity = activity;
            setOrientation(VERTICAL);
            LinearLayout bar = new LinearLayout(activity);
            bar.setGravity(Gravity.END | Gravity.CENTER_VERTICAL);
            // the full path of the folder like the one of the file dialog: another folder is opened with Enter
            path = activity.defaultText(new android.widget.EditText(activity));
            path.setSingleLine(true);
            path.setImeOptions(android.view.inputmethod.EditorInfo.IME_ACTION_GO | android.view.inputmethod.EditorInfo.IME_FLAG_NO_EXTRACT_UI);
            path.setInputType(android.text.InputType.TYPE_CLASS_TEXT | android.text.InputType.TYPE_TEXT_FLAG_NO_SUGGESTIONS);
            path.setPadding(activity.dp(4), activity.dp(2), activity.dp(4), activity.dp(2));
            path.setOnEditorActionListener(new TextView.OnEditorActionListener() {
                @Override
                public boolean onEditorAction(TextView view, int action, android.view.KeyEvent e) {
                    if (action != android.view.inputmethod.EditorInfo.IME_ACTION_GO && (e == null || e.getAction() != android.view.KeyEvent.ACTION_DOWN)) return false;
                    String folder = path.getText().toString().trim();
                    if (!folder.isEmpty() && new java.io.File(folder).isDirectory()) {
                        fill(folder, accept, multiple);
                        report("folder");
                    } else {
                        path.setText(dir);
                    }
                    return true;
                }
            });
            bar.addView(path, new LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f));
            iconButton = viewButton("icon", "Large icons");
            listButton = viewButton("list", "List");
            bar.addView(iconButton, new LinearLayout.LayoutParams(activity.dp(32), activity.dp(28)));
            bar.addView(listButton, new LinearLayout.LayoutParams(activity.dp(32), activity.dp(28)));
            addView(bar, new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT));
            adapter = new BaseAdapter() {
                @Override
                public int getCount() {
                    return names.size();
                }

                @Override
                public Object getItem(int position) {
                    return names.get(position);
                }

                @Override
                public long getItemId(int position) {
                    return position;
                }

                @Override
                public View getView(int position, View convertView, ViewGroup parent) {
                    return item(position, convertView, parent instanceof android.widget.GridView);
                }
            };
            android.widget.FrameLayout host = new android.widget.FrameLayout(activity);
            GradientDrawable border = new GradientDrawable();
            border.setColor(night(Color.WHITE, 0xFF1E1E1E));
            border.setStroke(Math.max(1, activity.dp(1)), night(0xFFC8C8C8, 0xFF555555));
            host.setBackground(border);
            host.setPadding(1, 1, 1, 1);
            list = new ListView(activity);
            grid = new android.widget.GridView(activity);
            grid.setNumColumns(android.widget.GridView.AUTO_FIT);
            grid.setColumnWidth(activity.dp(88));
            grid.setStretchMode(android.widget.GridView.STRETCH_SPACING_UNIFORM);
            grid.setVerticalSpacing(activity.dp(4));
            grid.setPadding(activity.dp(4), activity.dp(4), activity.dp(4), activity.dp(4));
            grid.setClipToPadding(false);
            for (AbsListView v : new AbsListView[]{list, grid}) {
                v.setAdapter(adapter);
                v.setChoiceMode(AbsListView.CHOICE_MODE_SINGLE);
                v.setOnItemClickListener(new android.widget.AdapterView.OnItemClickListener() {
                    @Override
                    public void onItemClick(android.widget.AdapterView<?> parent, View view, int position, long id) {
                        tap(position);
                    }
                });
                host.addView(v, new android.widget.FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
            }
            addView(host, new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 0, 1f));
            String saved = activity.getSharedPreferences("mff", Context.MODE_PRIVATE).getString("fileView", "list");
            setView("icon".equals(saved) ? "icon" : "list", false);
        }

        private ImageButton viewButton(final String name, String title) {
            ImageButton b = new ImageButton(activity);
            b.setImageDrawable(new android.graphics.drawable.BitmapDrawable(activity.getResources(), fileIcon(name, activity.dp(18))));
            b.setContentDescription(title);
            b.setScaleType(android.widget.ImageView.ScaleType.CENTER);
            b.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    setView(name, true);
                }
            });
            return b;
        }

        private AbsListView current() {
            return grid.getVisibility() == View.VISIBLE ? grid : list;
        }

        private void setView(String name, boolean save) {
            boolean icon = "icon".equals(name);
            AbsListView old = current();
            int checked = old.getCheckedItemPosition();
            grid.setVisibility(icon ? View.VISIBLE : View.GONE);
            list.setVisibility(icon ? View.GONE : View.VISIBLE);
            if (checked >= 0) current().setItemChecked(checked, true);
            // the button of the view is the pressed one
            iconButton.setBackground(viewButtonBack(icon));
            listButton.setBackground(viewButtonBack(!icon));
            if (save) activity.getSharedPreferences("mff", Context.MODE_PRIVATE).edit().putString("fileView", icon ? "icon" : "list").apply();
        }

        private android.graphics.drawable.Drawable viewButtonBack(boolean on) {
            GradientDrawable g = new GradientDrawable();
            g.setCornerRadius(activity.dp(3));
            g.setColor(on ? night(0xFFCCE4F7, 0xFF094771) : Color.TRANSPARENT);
            if (on) g.setStroke(Math.max(1, activity.dp(1)), 0xFF5B7FAE);
            return g;
        }

        // A row (List) or a cell (Large icons) of a folder or a file
        private View item(int position, View convertView, boolean icon) {
            String tag = icon ? "mffFileCell" : "mffFileRow";
            LinearLayout v = convertView instanceof LinearLayout && tag.equals(convertView.getTag()) ? (LinearLayout) convertView : null;
            if (v == null) {
                v = new LinearLayout(activity);
                v.setTag(tag);
                v.setOrientation(icon ? VERTICAL : HORIZONTAL);
                v.setGravity(icon ? Gravity.CENTER_HORIZONTAL : Gravity.CENTER_VERTICAL);
                v.setPadding(activity.dp(4), activity.dp(icon ? 4 : 3), activity.dp(4), activity.dp(icon ? 4 : 3));
                android.widget.ImageView picture = new android.widget.ImageView(activity);
                int size = activity.dp(icon ? 32 : 16);
                v.addView(picture, new LinearLayout.LayoutParams(size, size));
                TextView t = activity.defaultText(new TextView(activity));
                t.setDuplicateParentStateEnabled(true);
                t.setTextColor(new android.content.res.ColorStateList(new int[][]{{android.R.attr.state_activated}, {}}, new int[]{Color.WHITE, textColor()}));
                if (icon) {
                    t.setGravity(Gravity.CENTER_HORIZONTAL);
                    t.setMaxLines(2);
                    t.setPadding(0, activity.dp(2), 0, 0);
                } else {
                    t.setSingleLine(true);
                    t.setPadding(activity.dp(6), 0, 0, 0);
                }
                t.setEllipsize(android.text.TextUtils.TruncateAt.END);
                v.addView(t, new LinearLayout.LayoutParams(icon ? ViewGroup.LayoutParams.MATCH_PARENT : 0, ViewGroup.LayoutParams.WRAP_CONTENT, icon ? 0f : 1f));
                android.graphics.drawable.StateListDrawable back = new android.graphics.drawable.StateListDrawable();
                back.addState(new int[]{android.R.attr.state_activated}, new android.graphics.drawable.ColorDrawable(0xFF0078D7));
                back.addState(new int[]{}, new android.graphics.drawable.ColorDrawable(Color.TRANSPARENT));
                v.setBackground(back);
            }
            String name = names.get(position);
            String kind = name.equals("..") ? "up" : position < dirs ? "folder" : "file";
            int size = activity.dp(icon ? 32 : 16);
            ((android.widget.ImageView) v.getChildAt(0)).setImageBitmap(fileIcon(kind, size));
            ((TextView) v.getChildAt(1)).setText(name);
            return v;
        }

        private void tap(int position) {
            if (position < 0 || position >= names.size()) return;
            long now = android.os.SystemClock.uptimeMillis();
            boolean twice = position == lastTap && now - lastTapTime < 500;
            lastTap = position;
            lastTapTime = now;
            if (position < dirs) {
                String name = names.get(position);
                fill(name.equals("..") ? parent(dir) : join(dir, name), accept, multiple);
                report("folder");
            } else {
                report(twice ? "activate" : "select");
            }
        }

        // The file dialog (fileDialog) gets the changes itself, an OpenFileControl through onListChange
        interface Listener {
            void onChange(String event);
        }

        Listener listener;

        // The chosen files (their full paths)
        ArrayList<String> chosen() {
            ArrayList<String> paths = new ArrayList<>();
            AbsListView v = current();
            android.util.SparseBooleanArray checked = v.getCheckedItemPositions();
            for (int i = dirs; i < names.size(); i++) {
                if (checked != null ? checked.get(i) : v.getCheckedItemPosition() == i) paths.add(join(dir, names.get(i)));
            }
            return paths;
        }

        String folder() {
            return dir;
        }

        private void report(String event) {
            StringBuilder s = new StringBuilder(event).append('\n').append(dir);
            for (String p : chosen()) s.append('\n').append(p);
            state = s.toString();
            if (listener != null) listener.onChange(event);
            else activity.onListChange(this, Math.max(0, current().getCheckedItemPosition()));
        }

        private static String join(String dir, String name) {
            return dir.endsWith("/") ? dir + name : dir + "/" + name;
        }

        private static String parent(String dir) {
            int i = dir.lastIndexOf('/');
            return i <= 0 ? "/" : dir.substring(0, i);
        }

        void fill(String folder, java.util.regex.Pattern files, boolean many) {
            java.io.File f = new java.io.File(folder == null || folder.isEmpty() ? "/" : folder);
            if (!f.isDirectory()) f = activity.getFilesDir();
            dir = f.getAbsolutePath();
            if (dir.length() > 1 && dir.endsWith("/")) dir = dir.substring(0, dir.length() - 1);
            accept = files;
            multiple = many;
            visited.add(dir);
            ArrayList<String> folders = new ArrayList<>(), others = new ArrayList<>();
            java.io.File[] children = f.listFiles();
            if (children != null) {
                for (java.io.File c : children) {
                    if (c.isDirectory()) folders.add(c.getName());
                    else if (accept == null || accept.matcher(c.getName()).matches()) others.add(c.getName());
                }
            }
            // A folder of the system which the app cannot read (/storage/emulated/0/Android/data, ...) lists nothing: the
            // folders on the way to the ones of the app and to the visited ones are shown, the way back stays open
            String prefix = dir.equals("/") ? "/" : dir + "/";
            for (String known : reachable()) {
                if (!known.startsWith(prefix) || known.length() <= prefix.length()) continue;
                String name = known.substring(prefix.length());
                int slash = name.indexOf('/');
                if (slash >= 0) name = name.substring(0, slash);
                if (!name.isEmpty() && !folders.contains(name) && new java.io.File(prefix + name).isDirectory()) folders.add(name);
            }
            java.util.Collections.sort(folders, String.CASE_INSENSITIVE_ORDER);
            java.util.Collections.sort(others, String.CASE_INSENSITIVE_ORDER);
            names.clear();
            if (!dir.equals("/")) names.add("..");
            names.addAll(folders);
            dirs = names.size();
            names.addAll(others);
            lastTap = -1;
            for (AbsListView v : new AbsListView[]{list, grid}) {
                v.clearChoices();
                v.setChoiceMode(multiple ? AbsListView.CHOICE_MODE_MULTIPLE : AbsListView.CHOICE_MODE_SINGLE);
            }
            adapter.notifyDataSetChanged();
            list.setSelection(0);
            grid.setSelection(0);
            path.setText(dir);
            state = "\n" + dir;
        }

        // The folders which were opened in the file list
        private final HashSet<String> visited = new HashSet<>();

        // The folders of the app (its files, the documents of the user, its folder on the shared storage) and the opened
        // ones: the folders on the way to them are shown also where the system lets the app read nothing
        private ArrayList<String> reachable() {
            ArrayList<String> paths = new ArrayList<>(visited);
            java.io.File[] dirs = {activity.getFilesDir(), activity.getExternalFilesDir(null), android.os.Environment.getExternalStorageDirectory()};
            for (java.io.File d : dirs) if (d != null) paths.add(d.getAbsolutePath());
            for (String name : new String[]{"MFF_DOCUMENTS", "MFF_APPDIR", "HOME"}) {
                // Os.getenv: System.getenv does not see the variables of prepareAppFiles (Os.setenv)
                String value = Build.VERSION.SDK_INT >= 21 ? android.system.Os.getenv(name) : System.getenv(name);
                if (value != null && !value.isEmpty()) paths.add(value);
            }
            return paths;
        }

        // The pictures of the file list (the ones of the Web: an arrow up, a folder, a file) and of the view buttons
        private static final HashMap<String, android.graphics.Bitmap> icons = new HashMap<>();

        static android.graphics.Bitmap fileIcon(String kind, int size) {
            String key = kind + size;
            android.graphics.Bitmap b = icons.get(key);
            if (b != null) return b;
            b = android.graphics.Bitmap.createBitmap(size, size, android.graphics.Bitmap.Config.ARGB_8888);
            android.graphics.Canvas c = new android.graphics.Canvas(b);
            c.scale(size / 32f, size / 32f);
            android.graphics.Paint fill = new android.graphics.Paint(android.graphics.Paint.ANTI_ALIAS_FLAG);
            android.graphics.Paint line = new android.graphics.Paint(android.graphics.Paint.ANTI_ALIAS_FLAG);
            line.setStyle(android.graphics.Paint.Style.STROKE);
            line.setStrokeWidth(2);
            line.setStrokeJoin(android.graphics.Paint.Join.ROUND);
            line.setColor(0xFF5B7FAE);
            android.graphics.Path p = new android.graphics.Path();
            switch (kind) {
                case "folder":
                    fill.setColor(0xFFF5C95A);
                    p.moveTo(3, 8); p.lineTo(12, 8); p.lineTo(15, 11); p.lineTo(29, 11); p.lineTo(29, 26); p.lineTo(3, 26); p.close();
                    c.drawPath(p, fill);
                    line.setColor(0xFFC9962A);
                    c.drawPath(p, line);
                    break;
                case "up":
                    fill.setColor(0xFFF5C95A);
                    p.moveTo(3, 8); p.lineTo(12, 8); p.lineTo(15, 11); p.lineTo(29, 11); p.lineTo(29, 26); p.lineTo(3, 26); p.close();
                    c.drawPath(p, fill);
                    line.setStrokeWidth(3);
                    c.drawLine(16, 23, 16, 14, line);
                    c.drawLine(11, 18, 16, 13, line);
                    c.drawLine(21, 18, 16, 13, line);
                    break;
                case "file":
                    fill.setColor(Color.WHITE);
                    p.moveTo(7, 3); p.lineTo(20, 3); p.lineTo(26, 9); p.lineTo(26, 29); p.lineTo(7, 29); p.close();
                    c.drawPath(p, fill);
                    c.drawPath(p, line);
                    android.graphics.Path corner = new android.graphics.Path();
                    corner.moveTo(20, 3); corner.lineTo(20, 9); corner.lineTo(26, 9);
                    c.drawPath(corner, line);
                    break;
                case "icon":
                    fill.setColor(0xFF5B7FAE);
                    c.drawRect(4, 4, 14, 14, fill);
                    c.drawRect(18, 4, 28, 14, fill);
                    c.drawRect(4, 18, 14, 28, fill);
                    c.drawRect(18, 18, 28, 28, fill);
                    break;
                case "list":
                    fill.setColor(0xFF5B7FAE);
                    line.setStrokeWidth(3);
                    c.drawRect(3, 5, 8, 10, fill);
                    c.drawRect(3, 14, 8, 19, fill);
                    c.drawRect(3, 23, 8, 28, fill);
                    c.drawLine(11, 7.5f, 29, 7.5f, line);
                    c.drawLine(11, 16.5f, 29, 16.5f, line);
                    c.drawLine(11, 25.5f, 29, 25.5f, line);
                    break;
            }
            icons.put(key, b);
            return b;
        }
    }

    // Patterns "*.bas;*.bi" (* - any characters, ? - one character, the case is not checked; "*" and "*.*" - all the
    // files) of the files of the folder dir in the file list of an OpenFileControl
    public void fileViewFill(View v, String dir, String patterns, boolean multiple) {
        if (!(v instanceof MffFileView)) return;
        StringBuilder re = new StringBuilder();
        boolean all = false;
        for (String part : (patterns == null ? "*" : patterns).split(";")) {
            String pattern = part.trim();
            if (pattern.isEmpty()) continue;
            if (pattern.equals("*") || pattern.equals("*.*")) all = true;
            if (re.length() > 0) re.append('|');
            for (char ch : pattern.toCharArray()) {
                if (ch == '*') re.append(".*");
                else if (ch == '?') re.append('.');
                else re.append(java.util.regex.Pattern.quote(String.valueOf(ch)));
            }
        }
        ((MffFileView) v).fill(dir, all || re.length() == 0 ? null : java.util.regex.Pattern.compile(re.toString(), java.util.regex.Pattern.CASE_INSENSITIVE), multiple);
    }

    // The last change of the file list: the event, the folder and the chosen files, each one in a line
    public String fileViewState(View v) {
        return v instanceof MffFileView ? ((MffFileView) v).state : "";
    }

    // The empty AbsoluteLayout of activity_main.xml becomes an MffLayout: the Form can draw (OnPaint)
    private View formLayout(View v) {
        if (!(v instanceof AbsoluteLayout) || v instanceof MffLayout || ((ViewGroup) v).getChildCount() > 0
                || !(v.getParent() instanceof ViewGroup)) return v;
        ViewGroup parent = (ViewGroup) v.getParent();
        int index = parent.indexOfChild(v);
        MffLayout layout = new MffLayout(this);
        layout.setId(v.getId());
        layout.setBackground(v.getBackground());
        layout.setPadding(v.getPaddingLeft(), v.getPaddingTop(), v.getPaddingRight(), v.getPaddingBottom());
        ViewGroup.LayoutParams lp = v.getLayoutParams();
        parent.removeViewAt(index);
        parent.addView(layout, index, lp);
        return layout;
    }

    private static MffLayout drawn(View v) {
        if (v instanceof MffLayout && ((MffLayout) v).canvas != null) return (MffLayout) v;
        return null;
    }

    // FreeBasic colors are BGR (&hBBGGRR)
    private static int argb(int color, int alpha) {
        return Color.argb(alpha, color & 255, (color >> 8) & 255, (color >> 16) & 255);
    }

    private final HashSet<View> paintRequests = new HashSet<>();

    // Paints the view again: after the current message, once for several requests
    public void canvasRepaint(final View v) {
        if (!paintRequests.add(v)) return;
        v.post(new Runnable() {
            @Override
            public void run() {
                paintRequests.remove(v);
                if (drawn(v) != null) onPaint(v);
            }
        });
    }

    public void canvasBegin(View v) {
        MffLayout l = drawn(v);
        if (l == null) return;
        if (l.bitmap != null) l.bitmap.eraseColor(Color.TRANSPARENT);
        l.path.reset();
    }

    public void canvasEnd(View v) {
        v.invalidate();
    }

    public void canvasNewPath(View v) {
        MffLayout l = drawn(v);
        if (l != null) l.path.reset();
    }

    public void canvasMoveTo(View v, double x, double y) {
        MffLayout l = drawn(v);
        if (l != null) l.path.moveTo((float) x, (float) y);
    }

    public void canvasLineTo(View v, double x, double y) {
        MffLayout l = drawn(v);
        if (l != null) l.path.lineTo((float) x, (float) y);
    }

    public void canvasCurveTo(View v, double x1, double y1, double x2, double y2, double x3, double y3) {
        MffLayout l = drawn(v);
        if (l != null) l.path.cubicTo((float) x1, (float) y1, (float) x2, (float) y2, (float) x3, (float) y3);
    }

    // Like cairo_arc (cairo_arc_negative): from the angle a1 to a2 (radians, clockwise (counterclockwise) on the screen), joined to the current point
    public void canvasArc(View v, double cx, double cy, double r, double a1, double a2, boolean negative) {
        MffLayout l = drawn(v);
        if (l == null) return;
        if (negative) {
            while (a2 > a1) a2 -= 2 * Math.PI;
        } else {
            while (a2 < a1) a2 += 2 * Math.PI;
        }
        double sweep = Math.toDegrees(a2 - a1);
        android.graphics.RectF oval = new android.graphics.RectF((float) (cx - r), (float) (cy - r), (float) (cx + r), (float) (cy + r));
        // A full circle: G_PI of FreeBasic is short (359.99999 degrees), as a float it is 360 and arcTo draws nothing (mod 360)
        if (Math.abs(sweep) >= 359.99) {
            float half = sweep > 0 ? 180 : -180;
            l.path.arcTo(oval, (float) Math.toDegrees(a1), half, l.path.isEmpty());
            l.path.arcTo(oval, (float) Math.toDegrees(a1) + half, half, false);
        } else {
            l.path.arcTo(oval, (float) Math.toDegrees(a1), (float) sweep, l.path.isEmpty());
        }
    }

    public void canvasRectPath(View v, double x, double y, double w, double h) {
        MffLayout l = drawn(v);
        if (l != null) l.path.addRect((float) x, (float) y, (float) (x + w), (float) (y + h), android.graphics.Path.Direction.CW);
    }

    public void canvasClosePath(View v) {
        MffLayout l = drawn(v);
        if (l != null) l.path.close();
    }

    public void canvasFill(View v, int color, int alpha) {
        MffLayout l = drawn(v);
        if (l == null) return;
        android.graphics.Paint p = new android.graphics.Paint(android.graphics.Paint.ANTI_ALIAS_FLAG);
        p.setStyle(android.graphics.Paint.Style.FILL);
        p.setColor(argb(color, alpha));
        l.canvas.drawPath(l.path, p);
    }

    public void canvasStroke(View v, int color, int alpha, double width, String dash) {
        MffLayout l = drawn(v);
        if (l == null) return;
        android.graphics.Paint p = new android.graphics.Paint(android.graphics.Paint.ANTI_ALIAS_FLAG);
        p.setStyle(android.graphics.Paint.Style.STROKE);
        p.setColor(argb(color, alpha));
        p.setStrokeWidth(width > 0 ? (float) width : 1);
        if (dash != null && !dash.isEmpty()) {
            String[] parts = dash.split(",");
            float[] intervals = new float[parts.length % 2 == 0 ? parts.length : parts.length * 2];
            for (int i = 0; i < intervals.length; i++) intervals[i] = Float.parseFloat(parts[i % parts.length].trim());
            p.setPathEffect(new android.graphics.DashPathEffect(intervals, 0));
        }
        l.canvas.drawPath(l.path, p);
    }

    public void canvasFillRect(View v, double x, double y, double w, double h, int color, int alpha) {
        MffLayout l = drawn(v);
        if (l == null) return;
        android.graphics.Paint p = new android.graphics.Paint();
        p.setColor(argb(color, alpha));
        l.canvas.drawRect((float) x, (float) y, (float) (x + w), (float) (y + h), p);
    }

    // The z-order of the view among its siblings (BringToFront, SendToBack): top - over them, else under them.
    // v is the handle of any control (the one of the main Form is the activity)
    public void viewZOrder(Object v, int top) {
        if (!(v instanceof View) || !(((View) v).getParent() instanceof ViewGroup)) return;
        View view = (View) v;
        ViewGroup g = (ViewGroup) view.getParent();
        if (top != 0) {
            view.bringToFront();
        } else if (g.indexOfChild(view) > 0) {
            ViewGroup.LayoutParams lp = view.getLayoutParams();
            g.removeView(view);
            g.addView(view, 0, lp);
        }
        g.requestLayout();
        g.invalidate();
    }

    // ---- The designed form (the designer of the IDE): its view is lower than its place by the title bar, which is
    // drawn above it with the border around it like a window of Windows (FormDesignFrame of SysUtils.bas). The frame
    // is over the form and lets the touches through
    private final HashMap<View, DesignFrame> designFrames = new HashMap<>();

    static class DesignFrame extends View {
        String title = "";
        int caption;
        final android.graphics.Paint paint = new android.graphics.Paint(android.graphics.Paint.ANTI_ALIAS_FLAG);

        DesignFrame(Context context) {
            super(context);
            setClickable(false);
            setFocusable(false);
        }

        @Override
        protected void onDraw(android.graphics.Canvas c) {
            int w = getWidth(), h = getHeight();
            float d = getResources().getDisplayMetrics().density;
            int border = Math.max(1, Math.round(d));
            // the title bar
            paint.setStyle(android.graphics.Paint.Style.FILL);
            paint.setColor(night(Color.WHITE, 0xFF2D2D30));
            c.drawRect(0, 0, w, caption, paint);
            paint.setColor(textColor());
            paint.setTextSize(caption * 0.45f);
            android.graphics.Paint.FontMetrics fm = paint.getFontMetrics();
            float baseline = (caption - fm.ascent - fm.descent) / 2;
            float button = caption * 1.6f;
            c.save();
            c.clipRect(0, 0, Math.max(0, w - button * 3), caption);
            c.drawText(title, caption * 0.35f, baseline, paint);
            c.restore();
            // minimize, maximize, close
            paint.setStrokeWidth(Math.max(1, d));
            paint.setStyle(android.graphics.Paint.Style.STROKE);
            float s = caption * 0.16f, cy = caption / 2f;
            float x = w - button * 2.5f;
            c.drawLine(x - s, cy, x + s, cy, paint);
            x = w - button * 1.5f;
            c.drawRect(x - s, cy - s, x + s, cy + s, paint);
            x = w - button * 0.5f;
            c.drawLine(x - s, cy - s, x + s, cy + s, paint);
            c.drawLine(x - s, cy + s, x + s, cy - s, paint);
            // the border of the window
            paint.setColor(0xFF7A7A7A);
            paint.setStrokeWidth(border);
            c.drawRect(border / 2f, border / 2f, w - border / 2f, h - border / 2f, paint);
            c.drawLine(0, caption, w, caption, paint);
        }
    }

    public void formDesignFrame(Object v, String title, int captionPx) {
        if (!(v instanceof View) || !(((View) v).getParent() instanceof ViewGroup)) return;
        final View form = (View) v;
        DesignFrame frame = designFrames.get(form);
        if (frame == null) {
            final DesignFrame f = new DesignFrame(this);
            frame = f;
            designFrames.put(form, f);
            ViewGroup g = (ViewGroup) form.getParent();
            g.addView(f, g.indexOfChild(form) + 1, designFrameParams(form, captionPx));
            // the frame follows the bounds and the visibility of the form
            form.addOnLayoutChangeListener(new View.OnLayoutChangeListener() {
                @Override
                public void onLayoutChange(View view, int l, int t, int r, int b, int ol, int ot, int or, int ob) {
                    final ViewGroup.LayoutParams lp = designFrameParams(form, f.caption);
                    AbsoluteLayout.LayoutParams cur = (AbsoluteLayout.LayoutParams) f.getLayoutParams();
                    if (cur.x != ((AbsoluteLayout.LayoutParams) lp).x || cur.y != ((AbsoluteLayout.LayoutParams) lp).y
                            || cur.width != lp.width || cur.height != lp.height || f.getVisibility() != form.getVisibility()) {
                        f.post(new Runnable() {
                            @Override
                            public void run() {
                                f.setLayoutParams(lp);
                                f.setVisibility(form.getVisibility());
                            }
                        });
                    }
                }
            });
        }
        frame.title = title == null ? "" : title;
        frame.caption = captionPx;
        frame.setLayoutParams(designFrameParams(form, captionPx));
        frame.invalidate();
    }

    // The title bar of a second form (a layout in the one of its owner, not an Activity) like the one of a full-screen
    // dialog of Material: the close button at the left and the caption. It is a sibling of the form at the top of the
    // owner, the form is under it (Form.Show). The close button is the index -1 of onListChange of the form
    // (Form.ProcessMessage: CloseForm). visibility: 1 - shown, 0 - hidden, -1 - only the caption; the bar is made
    // when the form is shown
    private final java.util.WeakHashMap<View, LinearLayout> formBars = new java.util.WeakHashMap<>();

    public int formTitleBarHeight() {
        return dp(48);
    }

    // A full-screen dialog is in the layout of its owner: a form which was shown in its own activity (Show) is put back
    public void formAttach(Object v, Object parent) {
        if (!(v instanceof View) || !(parent instanceof ViewGroup)) return;
        View form = (View) v;
        if (form.getParent() == parent) return;
        if (form.getParent() instanceof ViewGroup) ((ViewGroup) form.getParent()).removeView(form);
        ((ViewGroup) parent).addView(form);
    }

    // A form of ShowModal over a form which fills its window (the main form, a form in its activity) is over the action
    // bar too like the dialogs of Android: it is put into a layout over the window (topHost) whose top is the one of the
    // action bar, its dim background covers the action bar. Returns the height of the action bar in pixels (where the
    // content of the owner begins in that layout); -1 - the owner does not fill its window (a modal form over a dialog
    // stays in the dialog: formAttach)
    public int formAttachTop(Object v, Object parent) {
        if (!(v instanceof View) || !(parent instanceof View)) return -1;
        View owner = (View) parent;
        View root = owner.getRootView();
        View content = root.findViewById(android.R.id.content);
        if (!(root instanceof android.widget.FrameLayout) || content == null || owner.getWidth() == 0 || owner.getHeight() == 0) return -1;
        int[] o = new int[2], c = new int[2];
        owner.getLocationInWindow(o);
        content.getLocationInWindow(c);
        if (o[0] != c[0] || o[1] != c[1] || owner.getWidth() != content.getWidth() || owner.getHeight() != content.getHeight()) return -1;
        int top = c[1];
        View bar = root.findViewById(androidx.appcompat.R.id.action_bar_container);
        if (bar != null && bar.isShown() && bar.getHeight() > 0) {
            int[] b = new int[2];
            bar.getLocationInWindow(b);
            top = Math.min(top, b[1]);
        }
        formAttach(v, topHost((android.widget.FrameLayout) root, content, top));
        return c[1] - top;
    }

    // The layout of the forms of ShowModal over the window (formAttachTop): from the top of the action bar to the bottom
    // of the content (it follows the content, the soft keyboard); empty it lets the touches through to the window
    private AbsoluteLayout topHost(android.widget.FrameLayout root, final View content, int top) {
        AbsoluteLayout host = root.findViewWithTag("mffTopHost");
        if (host == null) {
            host = new AbsoluteLayout(this);
            host.setTag("mffTopHost");
            root.addView(host);
            final AbsoluteLayout h = host;
            content.addOnLayoutChangeListener(new View.OnLayoutChangeListener() {
                @Override
                public void onLayoutChange(View view, int l, int t, int r, int b, int ol, int ot, int or, int ob) {
                    final android.widget.FrameLayout.LayoutParams lp = (android.widget.FrameLayout.LayoutParams) h.getLayoutParams();
                    int[] c = new int[2];
                    content.getLocationInWindow(c);
                    final int height = c[1] + content.getHeight() - lp.topMargin;
                    if (height != lp.height) h.post(new Runnable() {
                        @Override
                        public void run() {
                            lp.height = height;
                            h.setLayoutParams(lp);
                        }
                    });
                }
            });
        }
        int[] c = new int[2];
        content.getLocationInWindow(c);
        android.widget.FrameLayout.LayoutParams lp = new android.widget.FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, c[1] + content.getHeight() - top);
        lp.topMargin = top;
        host.setLayoutParams(lp);
        host.bringToFront();
        return host;
    }

    // Form.ShowModal waits in a nested message loop (modalRun) until the form is hidden (Form.Hide: formModalEnd)
    public void formModalWait(Object v) {
        if (!(v instanceof View) || modalWaits.contains(v)) return;
        modalRun(v);
    }

    public void formModalEnd(Object v) {
        modalEnd(v);
    }

    public void formTitleBar(Object v, String title, int visibility) {
        if (!(v instanceof View) || !(((View) v).getParent() instanceof ViewGroup)) return;
        final View form = (View) v;
        LinearLayout bar = formBars.get(form);
        if (bar == null) {
            if (visibility <= 0) return;
            bar = new LinearLayout(this);
            bar.setGravity(Gravity.CENTER_VERTICAL);
            bar.setBackgroundColor(night(Color.WHITE, 0xFF2D2D30));
            bar.setElevation(dp(4));
            Button close = defaultText(new Button(this));
            close.setText("✕");
            close.setTextSize(TypedValue.COMPLEX_UNIT_SP, 18);
            close.setTextColor(textColor());
            close.setMinWidth(0);
            close.setMinimumWidth(0);
            close.setMinHeight(0);
            close.setMinimumHeight(0);
            close.setBackground(flatButtonBackground(0));
            close.setStateListAnimator(null);
            close.setContentDescription("Close");
            close.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    onListChange(form, -1);
                }
            });
            bar.addView(close, new LinearLayout.LayoutParams(formTitleBarHeight(), ViewGroup.LayoutParams.MATCH_PARENT));
            TextView caption = new TextView(this);
            caption.setTextSize(TypedValue.COMPLEX_UNIT_SP, 20);
            caption.setTextColor(textColor());
            caption.setSingleLine(true);
            caption.setEllipsize(android.text.TextUtils.TruncateAt.END);
            caption.setPadding(dp(8), 0, dp(16), 0);
            bar.addView(caption, new LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f));
            formBars.put(form, bar);
            // the dim background under the dialog (a tablet: the dialog has its size): the controls of the owner do not
            // get the touches while the dialog is shown
            View scrim = new View(this);
            scrim.setBackgroundColor(0x99000000);
            scrim.setClickable(true);
            formScrims.put(form, scrim);
        }
        ((TextView) bar.getChildAt(1)).setText(title == null ? "" : title);
        if (visibility < 0) return;
        View scrim = formScrims.get(form);
        if (visibility == 0) {
            bar.setVisibility(View.GONE);
            scrim.setVisibility(View.GONE);
            // the open list of a ComboBox of the form (over it in the same layout) goes with it
            if (form.getParent() instanceof ViewGroup) closeSpinnerPopup((View) form.getParent());
            return;
        }
        // 2 - without the title bar (BorderStyle None), 8 - not modal (Show of a dialog or a tool window: the controls of
        // the owner get the touches, no dim background)
        boolean withBar = (visibility & 2) == 0, modal = (visibility & 8) == 0;
        // the form can be in another layout now (it was in its own activity, formAttach)
        ViewGroup g = (ViewGroup) form.getParent();
        if (scrim.getParent() != g) {
            if (scrim.getParent() instanceof ViewGroup) ((ViewGroup) scrim.getParent()).removeView(scrim);
            g.addView(scrim, new AbsoluteLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT, 0, 0));
        }
        if (bar.getParent() != g) {
            if (bar.getParent() instanceof ViewGroup) ((ViewGroup) bar.getParent()).removeView(bar);
            g.addView(bar);
        }
        // the bar is above the form with its width (the full width on a phone, Form.Show)
        int x = 0, y = formTitleBarHeight(), w = ViewGroup.LayoutParams.MATCH_PARENT;
        if (form.getLayoutParams() instanceof AbsoluteLayout.LayoutParams) {
            AbsoluteLayout.LayoutParams lp = (AbsoluteLayout.LayoutParams) form.getLayoutParams();
            x = lp.x;
            y = lp.y;
            w = lp.width;
        }
        bar.setLayoutParams(new AbsoluteLayout.LayoutParams(w, formTitleBarHeight(), x, Math.max(0, y - formTitleBarHeight())));
        scrim.setVisibility(modal ? View.VISIBLE : View.GONE);
        bar.setVisibility(withBar ? View.VISIBLE : View.GONE);
        if (modal) scrim.bringToFront();
        form.bringToFront();
        bar.bringToFront();
        // the forms of fsStayOnTop stay over the other forms of the layout
        for (View top : formsOnTop) {
            if (top == form || top.getParent() != g || top.getVisibility() != View.VISIBLE) continue;
            top.bringToFront();
            LinearLayout topBar = formBars.get(top);
            if (topBar != null && topBar.getParent() == g && topBar.getVisibility() == View.VISIBLE) topBar.bringToFront();
        }
    }

    private final java.util.Set<View> formsOnTop = java.util.Collections.newSetFromMap(new java.util.WeakHashMap<View, Boolean>());

    // FormStyle fsStayOnTop: the form is over the other forms in its owner (it is not in an activity of its own)
    public void formSetOnTop(Object v, boolean onTop) {
        if (!(v instanceof View)) return;
        if (onTop) formsOnTop.add((View) v);
        else formsOnTop.remove(v);
    }

    // The style of the main form (v = null) or of a second form (its FormActivity): 1 - without the action bar
    // (BorderStyle None), 2 - immersive (WindowState wsMaximized: the status bar and the navigation bar are hidden),
    // 4 - a dialog (BorderStyle FixedDialog): the close button instead of Up like a full-screen dialog of Material
    private final java.util.WeakHashMap<View, Integer> formStyles = new java.util.WeakHashMap<>();

    private int mainStyle;

    public void formSetStyle(Object v, int style) {
        if (v == null) {
            mainStyle = style;
            applyFormStyle(this, style);
            return;
        }
        if (!(v instanceof View)) return;
        formStyles.put((View) v, style);
        FormActivity a = formActivities.get(v);
        if (a != null) applyFormStyle(a, style);
    }

    @SuppressWarnings("deprecation")
    private static void applyFormStyle(AppCompatActivity a, int style) {
        if (a.getSupportActionBar() != null) {
            if ((style & 1) != 0) a.getSupportActionBar().hide();
            else a.getSupportActionBar().show();
            if (a instanceof FormActivity) {
                android.graphics.drawable.Drawable close = null;
                if ((style & 4) != 0) {
                    // the color of the Up arrow (the text of the action bar)
                    close = androidx.core.content.ContextCompat.getDrawable(a, android.R.drawable.ic_menu_close_clear_cancel);
                    if (close != null) {
                        close = androidx.core.graphics.drawable.DrawableCompat.wrap(close.mutate());
                        androidx.core.graphics.drawable.DrawableCompat.setTint(close, Color.WHITE);
                    }
                }
                a.getSupportActionBar().setHomeAsUpIndicator(close);
            }
        }
        View decor = a.getWindow().getDecorView();
        if ((style & 2) != 0) {
            decor.setSystemUiVisibility(View.SYSTEM_UI_FLAG_FULLSCREEN | View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
                    | (Build.VERSION.SDK_INT >= 19 ? View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY : 0)
                    | View.SYSTEM_UI_FLAG_LAYOUT_STABLE | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN | View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION);
        } else {
            decor.setSystemUiVisibility(View.SYSTEM_UI_FLAG_VISIBLE);
        }
    }

    // The bars of the system come back with the focus (a dialog): the immersive style again
    @Override
    public void onWindowFocusChanged(boolean hasFocus) {
        super.onWindowFocusChanged(hasFocus);
        if (hasFocus && (mainStyle & 2) != 0) applyFormStyle(this, mainStyle);
    }

    // WindowState wsMinimized (wsHide) of the main form: the program goes to the background like with Home
    public void activityMinimize() {
        moveTaskToBack(true);
    }

    private final java.util.WeakHashMap<View, View> formScrims = new java.util.WeakHashMap<>();

    // A modal form is a full-screen dialog on a phone, a dialog of its size on a tablet (Form.Show)
    public boolean formLargeScreen() {
        return getResources().getConfiguration().smallestScreenWidthDp >= 600;
    }

    // The frame is the title bar above the form and the border around it
    private ViewGroup.LayoutParams designFrameParams(View form, int captionPx) {
        int border = Math.max(1, Math.round(getResources().getDisplayMetrics().density));
        ViewGroup.LayoutParams lp = form.getLayoutParams();
        int x = 0, y = 0, w = form.getWidth(), h = form.getHeight();
        if (lp instanceof AbsoluteLayout.LayoutParams) {
            x = ((AbsoluteLayout.LayoutParams) lp).x;
            y = ((AbsoluteLayout.LayoutParams) lp).y;
            if (lp.width >= 0) w = lp.width;
            if (lp.height >= 0) h = lp.height;
        }
        return new AbsoluteLayout.LayoutParams(w + border * 2, h + captionPx + border, x - border, y - captionPx);
    }

    // The colors of the pixels are inverted (the caret: it is seen on a dark background too)
    public void canvasInvertRect(View v, double x, double y, double w, double h) {
        MffLayout l = drawn(v);
        if (l == null || l.bitmap == null) return;
        android.graphics.Rect r = new android.graphics.Rect((int) x, (int) y, (int) Math.ceil(x + w), (int) Math.ceil(y + h));
        if (!r.intersect(0, 0, l.bitmap.getWidth(), l.bitmap.getHeight())) return;
        // the pixels of the rectangle are drawn again with the inverted colors
        android.graphics.Bitmap part = android.graphics.Bitmap.createBitmap(l.bitmap, r.left, r.top, r.width(), r.height());
        android.graphics.Paint p = new android.graphics.Paint();
        p.setColorFilter(new android.graphics.ColorMatrixColorFilter(new float[]{
                -1, 0, 0, 0, 255,
                0, -1, 0, 0, 255,
                0, 0, -1, 0, 255,
                0, 0, 0, 1, 0}));
        l.canvas.drawBitmap(part, r.left, r.top, p);
        part.recycle();
    }

    // The current path is the clip of the next drawing (until canvasRestore), the path is cleared
    public void canvasClip(View v) {
        MffLayout l = drawn(v);
        if (l == null) return;
        l.canvas.clipPath(l.path);
        l.path.reset();
    }

    public void canvasSave(View v) {
        MffLayout l = drawn(v);
        if (l != null) l.canvas.save();
    }

    public void canvasRestore(View v) {
        MffLayout l = drawn(v);
        if (l != null) l.canvas.restore();
    }

    // The family of a font of Windows: Android has no Courier New, Consolas, Times New Roman..., an unknown name is the
    // default sans-serif font. A fixed width font (the code editor: its columns, tabs and spaces) stays fixed width
    private static android.graphics.Typeface fontFamily(String name) {
        if (name == null || name.isEmpty()) return android.graphics.Typeface.DEFAULT;
        String n = name.toLowerCase(java.util.Locale.ROOT);
        if (n.contains("mono") || n.contains("courier") || n.contains("consol") || n.contains("fixed") || n.contains("terminal")
                || n.equals("lucida console") || n.equals("lucida sans typewriter") || n.equals("cascadia code")) return android.graphics.Typeface.MONOSPACE;
        if (n.contains("times") || n.contains("georgia") || n.contains("garamond") || n.equals("serif")) return android.graphics.Typeface.SERIF;
        return android.graphics.Typeface.create(name, android.graphics.Typeface.NORMAL);
    }

    private static android.graphics.Paint textPaint(String fontName, double size, int bold, int italic) {
        android.graphics.Paint p = new android.graphics.Paint(android.graphics.Paint.ANTI_ALIAS_FLAG);
        int style = (bold != 0 ? android.graphics.Typeface.BOLD : 0) | (italic != 0 ? android.graphics.Typeface.ITALIC : 0);
        p.setTypeface(android.graphics.Typeface.create(fontFamily(fontName), style));
        p.setTextSize((float) size);
        return p;
    }

    // The text begins at y (its top) like TextOut of Windows; bkColor -1 is transparent
    public void canvasText(View v, double x, double y, String text, int color, int bkColor, String fontName, double size, int bold, int italic) {
        MffLayout l = drawn(v);
        if (l == null || text == null) return;
        android.graphics.Paint p = textPaint(fontName, size, bold, italic);
        android.graphics.Paint.FontMetrics fm = p.getFontMetrics();
        if (bkColor >= 0) {
            android.graphics.Paint b = new android.graphics.Paint();
            b.setColor(argb(bkColor, 255));
            l.canvas.drawRect((float) x, (float) y, (float) x + p.measureText(text), (float) y + fm.descent - fm.ascent, b);
        }
        p.setColor(argb(color, 255));
        l.canvas.drawText(text, (float) x, (float) y - fm.ascent, p);
    }

    public int canvasTextWidth(View v, String text, String fontName, double size, int bold, int italic) {
        return text == null ? 0 : (int) Math.ceil(textPaint(fontName, size, bold, italic).measureText(text));
    }

    public int canvasTextHeight(View v, String fontName, double size, int bold, int italic) {
        android.graphics.Paint.FontMetrics fm = textPaint(fontName, size, bold, italic).getFontMetrics();
        return (int) Math.ceil(fm.descent - fm.ascent);
    }

    // The color (BGR) of a pixel, -1 outside
    public int canvasGetPixel(View v, double x, double y) {
        MffLayout l = drawn(v);
        if (l == null || l.bitmap == null || x < 0 || y < 0 || x >= l.bitmap.getWidth() || y >= l.bitmap.getHeight()) return -1;
        int c = l.bitmap.getPixel((int) x, (int) y);
        return Color.red(c) | (Color.green(c) << 8) | (Color.blue(c) << 16);
    }

    private final HashMap<String, android.graphics.Bitmap> canvasImages = new HashMap<>();

    // A picture file or an asset; w/h -1 is the size of the picture
    public void canvasImage(View v, String path, double x, double y, double w, double h, int alpha) {
        MffLayout l = drawn(v);
        if (l == null || path == null || path.isEmpty()) return;
        android.graphics.Bitmap b = canvasImages.get(path);
        if (b == null) {
            b = android.graphics.BitmapFactory.decodeFile(path);
            if (b == null) {
                java.io.InputStream in = null;
                try {
                    String asset = path.replace("\\", "/");
                    if (asset.startsWith("./")) asset = asset.substring(2);
                    in = getAssets().open(asset);
                    b = android.graphics.BitmapFactory.decodeStream(in);
                } catch (Exception ex) {
                    Log.println(Log.WARN, "mff", "canvasImage: " + ex.getMessage());
                } finally {
                    try {
                        if (in != null) in.close();
                    } catch (Exception ignored) {
                    }
                }
            }
            if (b == null) return;
            canvasImages.put(path, b);
        }
        android.graphics.Paint p = new android.graphics.Paint(android.graphics.Paint.FILTER_BITMAP_FLAG);
        p.setAlpha(alpha);
        float fw = w < 0 ? b.getWidth() : (float) w, fh = h < 0 ? b.getHeight() : (float) h;
        l.canvas.drawBitmap(b, null, new android.graphics.RectF((float) x, (float) y, (float) x + fw, (float) y + fh), p);
    }

    // A page of PrintDocument: the canvas methods draw into a Picture (vectors, the text stays text in the PDF)
    // of width x height pixels; the recording ends when the page is shown or printed
    public static class MffPage extends MffLayout {
        final android.graphics.Picture picture = new android.graphics.Picture();
        final int pageWidth, pageHeight;

        public MffPage(Context context, int w, int h) {
            super(context);
            pageWidth = Math.max(1, w);
            pageHeight = Math.max(1, h);
            canvas = picture.beginRecording(pageWidth, pageHeight);
        }

        android.graphics.Picture finish() {
            if (canvas != null) {
                picture.endRecording();
                canvas = null;
            }
            return picture;
        }

        // The page scaled into the rectangle (the paper of the preview or of the printer)
        void drawInto(android.graphics.Canvas c, float x, float y, float w, float h) {
            finish();
            c.save();
            c.clipRect(x, y, x + w, y + h);
            c.translate(x, y);
            c.scale(w / pageWidth, h / pageHeight);
            c.drawPicture(picture);
            c.restore();
        }
    }

    public View pageCreate(int w, int h) {
        return new MffPage(this, w, h);
    }

    // Print Preview: the page on white paper with a border in the canvas of the view
    public void pageDraw(View v, View page, int x, int y, int w, int h) {
        MffLayout l = drawn(v);
        if (l == null || !(page instanceof MffPage) || w <= 0 || h <= 0) return;
        android.graphics.Paint p = new android.graphics.Paint();
        p.setColor(Color.WHITE);
        l.canvas.drawRect(x, y, x + w, y + h, p);
        p.setStyle(android.graphics.Paint.Style.STROKE);
        p.setColor(Color.BLACK);
        l.canvas.drawRect(x - 0.5f, y - 0.5f, x + w + 0.5f, y + h + 0.5f, p);
        ((MffPage) page).drawInto(l.canvas, x, y, w, h);
    }

    // The print dialog of Android: the pages are written as a PDF on the paper chosen in it (the paper of the
    // document is the first one, in tenths of a millimeter); a page fills the paper keeping its proportions
    public void printPages(View[] views, String title, int paperWidth, int paperHeight, boolean landscape) {
        if (views == null || views.length == 0) return;
        final java.util.ArrayList<MffPage> pages = new java.util.ArrayList<>();
        for (View v : views) if (v instanceof MffPage) pages.add((MffPage) v);
        if (pages.isEmpty()) return;
        final String name = title == null || title.isEmpty() ? "Document" : title;
        android.print.PrintManager pm = (android.print.PrintManager) getSystemService(Context.PRINT_SERVICE);
        if (pm == null) return;
        android.print.PrintDocumentAdapter adapter = new android.print.PrintDocumentAdapter() {
            android.print.PrintAttributes attributes;

            @Override
            public void onLayout(android.print.PrintAttributes oldAttributes, android.print.PrintAttributes newAttributes,
                                 android.os.CancellationSignal cancel, LayoutResultCallback callback, Bundle extras) {
                if (cancel.isCanceled()) {
                    callback.onLayoutCancelled();
                    return;
                }
                attributes = newAttributes;
                callback.onLayoutFinished(new android.print.PrintDocumentInfo.Builder(name + ".pdf")
                        .setContentType(android.print.PrintDocumentInfo.CONTENT_TYPE_DOCUMENT)
                        .setPageCount(pages.size()).build(), !newAttributes.equals(oldAttributes));
            }

            @Override
            public void onWrite(android.print.PageRange[] ranges, android.os.ParcelFileDescriptor destination,
                                android.os.CancellationSignal cancel, WriteResultCallback callback) {
                android.print.PrintAttributes.MediaSize media = attributes != null ? attributes.getMediaSize() : null;
                if (media == null) media = android.print.PrintAttributes.MediaSize.ISO_A4;
                // Points (1/72 inch) of the paper
                int pw = (int) Math.round(media.getWidthMils() * 72 / 1000.0), ph = (int) Math.round(media.getHeightMils() * 72 / 1000.0);
                android.graphics.pdf.PdfDocument pdf = new android.graphics.pdf.PdfDocument();
                java.io.FileOutputStream out = null;
                try {
                    for (int i = 0; i < pages.size(); i++) {
                        if (cancel.isCanceled()) {
                            callback.onWriteCancelled();
                            return;
                        }
                        MffPage page = pages.get(i);
                        android.graphics.pdf.PdfDocument.Page pdfPage = pdf.startPage(new android.graphics.pdf.PdfDocument.PageInfo.Builder(pw, ph, i + 1).create());
                        float scale = Math.min((float) pw / page.pageWidth, (float) ph / page.pageHeight);
                        page.drawInto(pdfPage.getCanvas(), 0, 0, page.pageWidth * scale, page.pageHeight * scale);
                        pdf.finishPage(pdfPage);
                    }
                    out = new java.io.FileOutputStream(destination.getFileDescriptor());
                    pdf.writeTo(out);
                    callback.onWriteFinished(new android.print.PageRange[]{android.print.PageRange.ALL_PAGES});
                } catch (Exception ex) {
                    callback.onWriteFailed(ex.getMessage());
                } finally {
                    pdf.close();
                    try {
                        if (out != null) out.close();
                    } catch (Exception ignored) {
                    }
                }
            }
        };
        // The paper of the document (Page Setup): mils are thousandths of an inch
        android.print.PrintAttributes.Builder b = new android.print.PrintAttributes.Builder();
        if (paperWidth > 0 && paperHeight > 0) {
            android.print.PrintAttributes.MediaSize media = new android.print.PrintAttributes.MediaSize("mff_paper", "Paper",
                    (int) Math.round(paperWidth * 1000 / 254.0), (int) Math.round(paperHeight * 1000 / 254.0));
            b.setMediaSize(landscape ? media.asLandscape() : media.asPortrait());
        }
        try {
            pm.print(name, adapter, b.build());
        } catch (Exception ex) {
            Log.println(Log.WARN, "mff", "printPages: " + ex.getMessage());
        }
    }

    /**
     * Implemented by the native library (Control.bas): the control of the view paints its canvas
     * (OnPaint and the drawing of the control).
     */
    public native void onPaint(View v);

    // A touch of the view goes to the native side as the mouse: onViewTouch(view, action, x, y),
    // action: 0 - down, 1 - up, 2 - move, 3 - cancel, 4 - move without a button (a mouse or a stylus over the view),
    // 5 - the mouse leaves the view. The MffLayouts take the touches (a tap is also a click),
    // the other views keep their own behavior.
    // The right button of Windows (the context menu of the designer, MouseButton 1): the right button of a mouse, or a
    // long press without moving (the press so far is released first, the rest of the touch is not sent). Actions of
    // onViewTouch: 6 - the right button is pressed, 7 - it is released
    public void setTouchEvent(View v) {
        final int slop = android.view.ViewConfiguration.get(this).getScaledTouchSlop();
        final float[] down = new float[2];
        final boolean[] state = new boolean[3]; // 0 - the right button is pressed (a mouse), 1 - the long press was sent, 2 - a finger scrolls
        final View target = v;
        final Runnable longPress = new Runnable() {
            @Override
            public void run() {
                state[1] = true;
                target.cancelLongPress();
                onViewTouch(target, 1, (int) down[0], (int) down[1]);
                onViewTouch(target, 6, (int) down[0], (int) down[1]);
                onViewTouch(target, 7, (int) down[0], (int) down[1]);
            }
        };
        v.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View view, android.view.MotionEvent e) {
                int action = e.getActionMasked();
                if (action > 3) return false;
                // the right button of a mouse
                if (action == 0 && Build.VERSION.SDK_INT >= 14 && (e.getButtonState() & android.view.MotionEvent.BUTTON_SECONDARY) != 0) {
                    state[0] = true;
                    onViewTouch(view, 6, (int) e.getX(), (int) e.getY());
                    return true;
                }
                if (state[0]) {
                    if (action == 1 || action == 3) {
                        state[0] = false;
                        onViewTouch(view, 7, (int) e.getX(), (int) e.getY());
                    } else {
                        onViewTouch(view, 2, (int) e.getX(), (int) e.getY());
                    }
                    return true;
                }
                // the long press: the touch stays at its place for the long press time of the system
                if (action == 0) {
                    state[1] = false;
                    down[0] = e.getX();
                    down[1] = e.getY();
                    view.removeCallbacks(longPress);
                    view.postDelayed(longPress, android.view.ViewConfiguration.getLongPressTimeout());
                } else if (action == 2 && (Math.abs(e.getX() - down[0]) > slop || Math.abs(e.getY() - down[1]) > slop)) {
                    view.removeCallbacks(longPress);
                } else if (action == 1 || action == 3) {
                    view.removeCallbacks(longPress);
                }
                // A view which takes the text (the code editor): a drag of a finger scrolls it up, down and sideways (the
                // native side makes notches of the wheel from the moves: onViewTouch 12 - the drag begins, 13 - it moves),
                // a mouse or a stylus selects the text
                if (view instanceof MffLayout && ((MffLayout) view).textInput && !state[1]
                        && e.getToolType(0) == android.view.MotionEvent.TOOL_TYPE_FINGER) {
                    if (action == 0) {
                        state[2] = false;
                    } else if (action == 2 && !state[2] && (Math.abs(e.getX() - down[0]) > slop || Math.abs(e.getY() - down[1]) > slop)) {
                        // the press of the touch is cancelled: the text is not selected
                        state[2] = true;
                        onViewTouch(view, 3, (int) e.getX(), (int) e.getY());
                        onViewTouch(view, 12, (int) e.getX(), (int) e.getY());
                    }
                    if (state[2]) {
                        if (action == 2) {
                            onViewTouch(view, 13, (int) e.getX(), (int) e.getY());
                        } else if (action == 1 || action == 3) {
                            state[2] = false;
                        }
                        return true;
                    }
                }
                if (state[1]) {
                    if (action == 1 || action == 3) {
                        state[1] = false;
                        // the widget (a Button, ...) is not clicked after the long press
                        if (!(view instanceof MffLayout)) {
                            android.view.MotionEvent cancel = android.view.MotionEvent.obtain(e);
                            cancel.setAction(android.view.MotionEvent.ACTION_CANCEL);
                            view.onTouchEvent(cancel);
                            cancel.recycle();
                        }
                    }
                    return true;
                }
                onViewTouch(view, action, (int) e.getX(), (int) e.getY());
                if (!(view instanceof MffLayout)) return false;
                if (action == 1) view.performClick();
                // A view which takes the text (setKeyEvent) shows the soft keyboard when it is touched
                if (action == 1 && ((MffLayout) view).textInput) showSoftKeyboard(view);
                return true;
            }
        });
        // The mouse wheel: a notch is onViewTouch 8 (up), 9 (down), 10 (left) or 11 (right) at the point of the mouse
        v.setOnGenericMotionListener(new View.OnGenericMotionListener() {
            @Override
            public boolean onGenericMotion(View view, android.view.MotionEvent e) {
                if ((e.getSource() & android.view.InputDevice.SOURCE_CLASS_POINTER) == 0 || e.getAction() != android.view.MotionEvent.ACTION_SCROLL) return false;
                float delta = e.getAxisValue(android.view.MotionEvent.AXIS_VSCROLL);
                float hDelta = e.getAxisValue(android.view.MotionEvent.AXIS_HSCROLL);
                if (delta == 0 && hDelta == 0) return false;
                // AXIS_VSCROLL > 0 - up (8), < 0 - down (9); AXIS_HSCROLL > 0 - right (11), < 0 - left (10)
                if (delta != 0) {
                    int notches = Math.max(1, Math.round(Math.abs(delta)));
                    for (int i = 0; i < notches; i++) onViewTouch(view, delta > 0 ? 8 : 9, (int) e.getX(), (int) e.getY());
                }
                if (hDelta != 0) {
                    int notches = Math.max(1, Math.round(Math.abs(hDelta)));
                    for (int i = 0; i < notches; i++) onViewTouch(view, hDelta > 0 ? 11 : 10, (int) e.getX(), (int) e.getY());
                }
                return view instanceof MffLayout;
            }
        });
        // The touch screen has no hover: only a mouse (or a stylus) moves over the view without pressing
        v.setOnHoverListener(new View.OnHoverListener() {
            @Override
            public boolean onHover(View view, android.view.MotionEvent e) {
                int action = e.getActionMasked();
                if (action == android.view.MotionEvent.ACTION_HOVER_ENTER || action == android.view.MotionEvent.ACTION_HOVER_MOVE) {
                    onViewTouch(view, 4, (int) e.getX(), (int) e.getY());
                } else if (action == android.view.MotionEvent.ACTION_HOVER_EXIT) {
                    onViewTouch(view, 5, (int) e.getX(), (int) e.getY());
                } else {
                    return false;
                }
                return view instanceof MffLayout;
            }
        });
    }

    /**
     * Implemented by the native library (Control.bas): CM_MOUSE* messages and the OnMouse* events of the control.
     * action: 0 - down, 1 - up, 2 - move, 3 - cancel, 4 - hover, 5 - hover exit, 6/7 - the right button down/up,
     * 8/9 - a notch of the mouse wheel up/down, 10/11 - left/right, 12/13 - a drag of a finger in a view which takes
     * the text begins/moves (x, y - the point of the finger).
     */
    public native void onViewTouch(View v, int action, int x, int y);

    // The keys of the view go to the native side: onViewKey(view, action, key, state), action: 0 - down, 1 - up,
    // 2 - a character, 3 - the view got the focus, 4 - lost it; key - the key code of Windows (VK_*) or the character,
    // state: 1 - Shift, 2 - Ctrl, 4 - Alt. textInput: the view (an MffLayout) takes the text of the soft keyboard
    public void setKeyEvent(View v, final boolean textInput) {
        v.setFocusable(true);
        v.setFocusableInTouchMode(true);
        if (v instanceof MffLayout) ((MffLayout) v).textInput = textInput;
        v.setOnKeyListener(new View.OnKeyListener() {
            @Override
            public boolean onKey(View view, int keyCode, android.view.KeyEvent e) {
                return sendViewKey(view, e);
            }
        });
        v.setOnFocusChangeListener(new View.OnFocusChangeListener() {
            @Override
            public void onFocusChange(View view, boolean hasFocus) {
                onViewKey(view, hasFocus ? 3 : 4, 0, 0);
            }
        });
    }

    public void showSoftKeyboard(View v) {
        v.requestFocus();
        android.view.inputmethod.InputMethodManager imm = (android.view.inputmethod.InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
        if (imm != null) imm.showSoftInput(v, android.view.inputmethod.InputMethodManager.SHOW_IMPLICIT);
    }

    // The key codes of Android as the ones of Windows (VK_*), 0 - a key without a code of Windows
    private static int keyToVirtualKey(int keyCode) {
        if (keyCode >= android.view.KeyEvent.KEYCODE_A && keyCode <= android.view.KeyEvent.KEYCODE_Z) return 'A' + keyCode - android.view.KeyEvent.KEYCODE_A;
        if (keyCode >= android.view.KeyEvent.KEYCODE_0 && keyCode <= android.view.KeyEvent.KEYCODE_9) return '0' + keyCode - android.view.KeyEvent.KEYCODE_0;
        if (keyCode >= android.view.KeyEvent.KEYCODE_F1 && keyCode <= android.view.KeyEvent.KEYCODE_F12) return 112 + keyCode - android.view.KeyEvent.KEYCODE_F1;
        // the numeric keypad: VK_NUMPAD0 - VK_NUMPAD9, VK_MULTIPLY, VK_ADD, VK_SUBTRACT, VK_DECIMAL, VK_DIVIDE
        if (keyCode >= android.view.KeyEvent.KEYCODE_NUMPAD_0 && keyCode <= android.view.KeyEvent.KEYCODE_NUMPAD_9) return 96 + keyCode - android.view.KeyEvent.KEYCODE_NUMPAD_0;
        switch (keyCode) {
            case android.view.KeyEvent.KEYCODE_NUMPAD_MULTIPLY: return 106;
            case android.view.KeyEvent.KEYCODE_NUMPAD_ADD: return 107;
            case android.view.KeyEvent.KEYCODE_NUMPAD_SUBTRACT: return 109;
            case android.view.KeyEvent.KEYCODE_NUMPAD_DOT: return 110;
            case android.view.KeyEvent.KEYCODE_NUMPAD_DIVIDE: return 111;
        }
        switch (keyCode) {
            case android.view.KeyEvent.KEYCODE_DEL: return 8;
            case android.view.KeyEvent.KEYCODE_TAB: return 9;
            case android.view.KeyEvent.KEYCODE_ENTER: case android.view.KeyEvent.KEYCODE_NUMPAD_ENTER: return 13;
            case android.view.KeyEvent.KEYCODE_ESCAPE: return 27;
            case android.view.KeyEvent.KEYCODE_SPACE: return 32;
            case android.view.KeyEvent.KEYCODE_PAGE_UP: return 33;
            case android.view.KeyEvent.KEYCODE_PAGE_DOWN: return 34;
            case android.view.KeyEvent.KEYCODE_MOVE_END: return 35;
            case android.view.KeyEvent.KEYCODE_MOVE_HOME: return 36;
            case android.view.KeyEvent.KEYCODE_DPAD_LEFT: return 37;
            case android.view.KeyEvent.KEYCODE_DPAD_UP: return 38;
            case android.view.KeyEvent.KEYCODE_DPAD_RIGHT: return 39;
            case android.view.KeyEvent.KEYCODE_DPAD_DOWN: return 40;
            case android.view.KeyEvent.KEYCODE_INSERT: return 45;
            case android.view.KeyEvent.KEYCODE_FORWARD_DEL: return 46;
            case android.view.KeyEvent.KEYCODE_SHIFT_LEFT: case android.view.KeyEvent.KEYCODE_SHIFT_RIGHT: return 16;
            case android.view.KeyEvent.KEYCODE_CTRL_LEFT: case android.view.KeyEvent.KEYCODE_CTRL_RIGHT: return 17;
            case android.view.KeyEvent.KEYCODE_ALT_LEFT: case android.view.KeyEvent.KEYCODE_ALT_RIGHT: return 18;
        }
        return 0;
    }

    // A key of the soft keyboard without a KeyEvent (Enter, Backspace, Delete): down, the character of Enter, up
    void sendViewVirtualKey(View view, int vk) {
        onViewKey(view, 0, vk, 0);
        if (vk == 13) onViewKey(view, 2, 13, 0);
        onViewKey(view, 1, vk, 0);
    }

    // The arrows of the keyboard of the emulator (qwerty2): the emulator turns them with the screen like a D-pad of a
    // phone (in the landscape Up comes as Right), they are turned back. 0 - not such an arrow
    private int arrowToVirtualKey(android.view.KeyEvent e) {
        int index;
        switch (e.getKeyCode()) {
            case android.view.KeyEvent.KEYCODE_DPAD_UP: index = 0; break;
            case android.view.KeyEvent.KEYCODE_DPAD_RIGHT: index = 1; break;
            case android.view.KeyEvent.KEYCODE_DPAD_DOWN: index = 2; break;
            case android.view.KeyEvent.KEYCODE_DPAD_LEFT: index = 3; break;
            default: return 0;
        }
        android.view.InputDevice device = e.getDevice();
        if (device == null || !"qwerty2".equals(device.getName())) return 0;
        int rotation = getWindowManager().getDefaultDisplay().getRotation();
        // Up, Right, Down, Left clockwise: the emulator gives the arrow turned by the rotation of the screen
        final int[] keys = {38, 39, 40, 37};
        return keys[(index - rotation + 4) % 4];
    }

    // The keys of the numeric keypad by their scan code (Linux KEY_KP*) when the key layout of the keyboard has no key
    // code for them (KEYCODE_UNKNOWN: the keyboard of the emulator, qwerty.kl): the virtual key and the character
    private static int[] keypadByScanCode(int scanCode) {
        switch (scanCode) {
            case 96: return new int[]{13, 13};
            case 82: return new int[]{96, '0'};
            case 79: return new int[]{97, '1'};
            case 80: return new int[]{98, '2'};
            case 81: return new int[]{99, '3'};
            case 75: return new int[]{100, '4'};
            case 76: return new int[]{101, '5'};
            case 77: return new int[]{102, '6'};
            case 71: return new int[]{103, '7'};
            case 72: return new int[]{104, '8'};
            case 73: return new int[]{105, '9'};
            case 55: return new int[]{106, '*'};
            case 78: return new int[]{107, '+'};
            case 74: return new int[]{109, '-'};
            case 83: return new int[]{110, '.'};
            case 98: return new int[]{111, '/'};
        }
        return null;
    }

    boolean sendViewKey(View view, android.view.KeyEvent e) {
        int vk = arrowToVirtualKey(e);
        if (vk == 0) vk = keyToVirtualKey(e.getKeyCode());
        int[] keypad = e.getKeyCode() == android.view.KeyEvent.KEYCODE_UNKNOWN ? keypadByScanCode(e.getScanCode()) : null;
        if (keypad != null) vk = keypad[0];
        int state = (e.isShiftPressed() ? 1 : 0) | (e.isCtrlPressed() ? 2 : 0) | (e.isAltPressed() ? 4 : 0);
        switch (e.getAction()) {
            case android.view.KeyEvent.ACTION_DOWN:
                if (vk != 0) onViewKey(view, 0, vk, state);
                // Like the characters of Windows: Enter is 13, Backspace / Tab / Escape have only the key
                int c = vk == 13 ? 13 : keypad != null ? ((state & 2) != 0 ? 0 : keypad[1])
                        : (vk == 8 || vk == 9 || vk == 27 || (state & 2) != 0 ? 0 : e.getUnicodeChar(e.getMetaState()));
                if (c > 0) onViewKey(view, 2, c, state);
                return vk != 0 || c > 0;
            case android.view.KeyEvent.ACTION_UP:
                if (vk != 0) onViewKey(view, 1, vk, state);
                return vk != 0;
            case android.view.KeyEvent.ACTION_MULTIPLE:
                String s = e.getCharacters();
                if (s == null) return false;
                for (int i = 0; i < s.length(); ) {
                    int cp = s.codePointAt(i);
                    onViewKey(view, 2, cp, state);
                    i += Character.charCount(cp);
                }
                return true;
        }
        return false;
    }

    /**
     * Implemented by the native library (Control.bas): CM_KEYDOWN, CM_KEYUP, CM_CHAR, CM_SETFOCUS, CM_KILLFOCUS
     * and the OnKey* / focus events of the control.
     */
    public native void onViewKey(View v, int action, int key, int state);

    // Mode: 0 - single choice, 1 - multiple choice (check boxes), 2 - no choice, 3 - single choice which is shown as the
    // selected row (the tables: TreeView, ListView, TreeListView like the ones of Windows, without radio buttons)
    public void listInitMode(View v, int mode) {
        // ListView, or GridView (IconGrid: a ListView of View vsIcon)
        if (!(v instanceof AbsListView)) {
            listInit(v);
            return;
        }
        AbsListView lv = (AbsListView) v;
        int layout = mode == 1 ? android.R.layout.simple_list_item_multiple_choice
                : mode == 2 ? android.R.layout.simple_list_item_1
                : mode == 3 ? android.R.layout.simple_list_item_activated_1 : android.R.layout.simple_list_item_single_choice;
        lv.setAdapter(mode == 3 ? tableAdapter(lv) : listAdapter(layout));
        lv.setChoiceMode(mode == 1 ? AbsListView.CHOICE_MODE_MULTIPLE : mode == 2 ? AbsListView.CHOICE_MODE_NONE : AbsListView.CHOICE_MODE_SINGLE);
        lv.setOnItemClickListener(this);
    }

    public void listSetChecked(View v, int index, boolean checked) {
        if (v instanceof AbsListView) ((AbsListView) v).setItemChecked(index + headerRows(v), checked);
    }

    public boolean listGetChecked(View v, int index) {
        return v instanceof AbsListView && ((AbsListView) v).isItemChecked(index + headerRows(v));
    }

    public void viewSetText(View v, String text) {
        if (v instanceof TextView) ((TextView) v).setText(text);
        else if (v instanceof ViewGroup && v.findViewWithTag("mffGroupCaption") != null) groupSetTitle(v, text);
    }

    // Text with HTML markup (LinkLabel: the links are opened by the system)
    @SuppressWarnings("deprecation")
    public void viewSetHtml(View v, String html) {
        if (!(v instanceof TextView)) return;
        // an empty string of the FreeBasic side comes as null
        if (html == null) html = "";
        TextView t = (TextView) v;
        t.setText(Build.VERSION.SDK_INT >= 24 ? android.text.Html.fromHtml(html, android.text.Html.FROM_HTML_MODE_LEGACY) : android.text.Html.fromHtml(html));
        t.setMovementMethod(LinkMovementMethod.getInstance());
    }

    public void openUrl(String url) {
        try {
            startActivity(new Intent(Intent.ACTION_VIEW, android.net.Uri.parse(url)));
        } catch (Exception ex) {
            Log.println(Log.WARN, "mff", "openUrl: " + ex.getMessage());
        }
    }

    // Regular expressions of Regex.bas (RegexCompile, RegexExec, ... in SysUtils.bas)
    private final HashMap<Integer, java.util.regex.Pattern> regexPatterns = new HashMap<>();
    private int regexNextId = 1;
    private String regexLastError = "";

    // Flags: 1 - ignore case, 2 - multiline, 4 - dot matches all, 8 - extended; returns 0 on an error
    public int regexCompile(String pattern, int flags) {
        int f = 0;
        if ((flags & 1) != 0) f |= java.util.regex.Pattern.CASE_INSENSITIVE | java.util.regex.Pattern.UNICODE_CASE;
        if ((flags & 2) != 0) f |= java.util.regex.Pattern.MULTILINE;
        if ((flags & 4) != 0) f |= java.util.regex.Pattern.DOTALL;
        if ((flags & 8) != 0) f |= java.util.regex.Pattern.COMMENTS;
        try {
            int id = regexNextId++;
            regexPatterns.put(id, java.util.regex.Pattern.compile(pattern, f));
            regexLastError = "";
            return id;
        } catch (java.util.regex.PatternSyntaxException ex) {
            regexLastError = ex.getMessage();
            return 0;
        }
    }

    public String regexError() {
        return regexLastError;
    }

    public void regexFree(int id) {
        regexPatterns.remove(id);
    }

    // The subject and all offsets are in UTF-8 bytes; offsets gets the start and end of each group (-1 - not matched)
    public int regexExec(int id, byte[] subject, int startByte, int[] offsets) {
        java.util.regex.Pattern p = regexPatterns.get(id);
        if (p == null) return 0;
        java.nio.charset.Charset utf8 = java.nio.charset.StandardCharsets.UTF_8;
        String s = new String(subject, utf8);
        int start = new String(subject, 0, Math.min(Math.max(startByte, 0), subject.length), utf8).length();
        java.util.regex.Matcher m = p.matcher(s);
        if (!m.find(start)) return 0;
        int count = Math.min(m.groupCount() + 1, offsets.length / 2);
        for (int i = 0; i < count; i++) {
            if (m.start(i) < 0) {
                offsets[2 * i] = -1;
                offsets[2 * i + 1] = -1;
            } else {
                offsets[2 * i] = s.substring(0, m.start(i)).getBytes(utf8).length;
                offsets[2 * i + 1] = s.substring(0, m.end(i)).getBytes(utf8).length;
            }
        }
        return count;
    }

    // Modal dialogs of Dialogs.bas (ShowFileDialog, ... in SysUtils.bas). The native code waits for the answer:
    // the dialog runs a nested message loop which a ModalExit thrown by modalEnd leaves
    private static class ModalExit extends RuntimeException {
    }

    // The waits (a dialog, a form of ShowModal, the start of a FormActivity) in the order of their loops and the ended
    // ones. A loop ends when its wait has ended; the waits can end in any order (a form of ShowModal under another
    // one is hidden first): a loop under the last one ends when the last one has ended too
    private final ArrayList<Object> modalWaits = new ArrayList<>();
    private final HashSet<Object> modalEnded = new HashSet<>();

    private void modalRun(Object wait) {
        modalWaits.add(wait);
        try {
            while (!modalEnded.contains(wait)) {
                try {
                    android.os.Looper.loop();
                } catch (ModalExit ex) {
                    // the last loop leaves: its wait or one over it (it waits again then) ended
                }
            }
        } finally {
            modalEnded.remove(wait);
            modalWaits.remove(wait);
        }
        if (!modalWaits.isEmpty() && modalEnded.contains(modalWaits.get(modalWaits.size() - 1))) modalExit();
    }

    private void modalEnd(Object wait) {
        if (!modalWaits.contains(wait)) return;
        modalEnded.add(wait);
        if (modalWaits.get(modalWaits.size() - 1) == wait) modalExit();
    }

    private void modalExit() {
        new android.os.Handler(android.os.Looper.getMainLooper()).post(new Runnable() {
            @Override
            public void run() {
                throw new ModalExit();
            }
        });
    }

    // The results of the dialogs given to modalClose (or by their buttons)
    private final HashMap<Object, String> modalResults = new HashMap<>();

    // Shows the dialog, waits until it is closed and returns the result given to modalClose (null - cancelled)
    private String modalShow(final android.app.AlertDialog dialog) {
        modalResults.remove(dialog);
        dialog.setOnDismissListener(new android.content.DialogInterface.OnDismissListener() {
            @Override
            public void onDismiss(android.content.DialogInterface d) {
                modalEnd(dialog);
            }
        });
        dialog.show();
        modalRun(dialog);
        return modalResults.remove(dialog);
    }

    private void modalClose(android.app.AlertDialog dialog, String result) {
        modalResults.put(dialog, result);
        dialog.dismiss();
    }

    // MsgBox (Application.bas): an AlertDialog with the title, the text and the buttons of ButtonsType.
    // type: MessageType (0 - info, 1 - warning, 2 - question, 3 - error, 4 - other);
    // buttons: ButtonsType (0 - none, 1 - OK, 2 - Yes No, 3 - Yes No Cancel, 4 - OK Cancel).
    // Returns MessageResult: 1 - mrCancel, 3 - mrNo, 4 - mrOK, 6 - mrYes. Back is Cancel (OK when there is no
    // Cancel button); Yes No has no Cancel, it is not closed with Back like the message box of Windows
    public int messageBox(String text, String caption, int type, int buttons) {
        final int mrCancel = 1, mrNo = 3, mrOK = 4, mrYes = 6;
        android.app.AlertDialog.Builder builder = new android.app.AlertDialog.Builder(dialogOwner())
                .setTitle(caption)
                .setMessage(text);
        if (type == 0 || type == 2) builder.setIcon(android.R.drawable.ic_dialog_info);
        else if (type == 1 || type == 3) builder.setIcon(android.R.drawable.ic_dialog_alert);
        final String[] codes = new String[3];
        if (buttons == 2 || buttons == 3) {
            codes[0] = String.valueOf(mrYes);
            codes[1] = String.valueOf(mrNo);
            if (buttons == 3) codes[2] = String.valueOf(mrCancel);
        } else {
            codes[0] = String.valueOf(mrOK);
            if (buttons == 4) codes[1] = String.valueOf(mrCancel);
        }
        android.content.DialogInterface.OnClickListener click = new android.content.DialogInterface.OnClickListener() {
            @Override
            public void onClick(android.content.DialogInterface d, int which) {
                if (which == android.content.DialogInterface.BUTTON_POSITIVE) modalResults.put(d, codes[0]);
                else if (which == android.content.DialogInterface.BUTTON_NEGATIVE) modalResults.put(d, codes[1]);
                else if (which == android.content.DialogInterface.BUTTON_NEUTRAL) modalResults.put(d, codes[2]);
            }
        };
        // android.R.string.yes and no are "OK" and "Cancel" on the newer versions of Android
        boolean yesNo = buttons == 2 || buttons == 3;
        if (yesNo) builder.setPositiveButton("Yes", click);
        else builder.setPositiveButton(android.R.string.ok, click);
        if (codes[1] != null) {
            if (yesNo) builder.setNegativeButton("No", click);
            else builder.setNegativeButton(android.R.string.cancel, click);
        }
        if (codes[2] != null) builder.setNeutralButton(android.R.string.cancel, click);
        android.app.AlertDialog dialog = builder.create();
        dialog.setCancelable(buttons != 2);
        dialog.setCanceledOnTouchOutside(false);
        String result = modalShow(dialog);
        if (result == null) return buttons == 3 || buttons == 4 ? mrCancel : mrOK;
        return Integer.parseInt(result);
    }

    private int dp(int value) {
        return (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, value, getResources().getDisplayMetrics());
    }

    // "Text files|*.txt;*.log|All files|*.*" -> the descriptions and the patterns as regular expressions
    // exts - the extensions of the first patterns ("*.bas" - ".bas") which Save adds to a name without it
    private static void parseFilter(String filter, ArrayList<String> texts, ArrayList<java.util.regex.Pattern> patterns, ArrayList<String> exts) {
        String[] parts = filter.split("\\|");
        for (int i = 0; i + 1 < parts.length; i += 2) {
            String first = parts[i + 1].split(";")[0].trim();
            exts.add(first.matches("\\*\\.[^*?]+") ? first.substring(1) : "");
            StringBuilder re = new StringBuilder();
            for (String glob : parts[i + 1].split(";")) {
                if (re.length() > 0) re.append('|');
                for (char c : glob.trim().toCharArray()) {
                    if (c == '*') re.append(".*");
                    else if (c == '?') re.append('.');
                    else re.append(java.util.regex.Pattern.quote(String.valueOf(c)));
                }
            }
            texts.add(parts[i]);
            patterns.add(java.util.regex.Pattern.compile("^(" + re + ")$", java.util.regex.Pattern.CASE_INSENSITIVE));
        }
    }

    // Mode: 0 - open, 1 - open several files, 2 - save, 3 - folder. Returns the paths separated with "\n", null - cancelled
    public String fileDialog(final int mode, String caption, String initialDir, String fileName, String filter, int filterIndex) {
        // an empty string of the native side comes as null
        if (caption == null) caption = "";
        if (initialDir == null) initialDir = "";
        if (fileName == null) fileName = "";
        if (filter == null) filter = "";
        java.io.File dir = new java.io.File(initialDir.isEmpty() ? getFilesDir().getAbsolutePath() : initialDir);
        if (fileName.contains("/")) {
            java.io.File f = new java.io.File(fileName);
            if (initialDir.isEmpty() && f.getParentFile() != null) dir = f.getParentFile();
            fileName = f.getName();
        }
        if (!dir.isDirectory()) dir = getFilesDir();
        final java.io.File[] current = { dir };
        final ArrayList<String> filterTexts = new ArrayList<>();
        final ArrayList<java.util.regex.Pattern> filterPatterns = new ArrayList<>();
        final ArrayList<String> filterExts = new ArrayList<>();
        parseFilter(filter, filterTexts, filterPatterns, filterExts);

        // Like the file dialog of the Web: the file list (the full path, the views "Large icons" and "List") and under
        // it the file name with the types of the filter. A tap on a file is its name, a double tap is OK
        LinearLayout layout = new LinearLayout(this);
        layout.setOrientation(LinearLayout.VERTICAL);
        layout.setPadding(dp(16), dp(8), dp(16), 0);
        final MffFileView list = new MffFileView(this);
        // the rest of the screen under the title, the path, the file name and the buttons (a phone in landscape)
        int listHeight = Math.max(dp(120), Math.min(dp(300), getResources().getDisplayMetrics().heightPixels - dp(270)));
        layout.addView(list, new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, listHeight));
        LinearLayout row = new LinearLayout(this);
        row.setGravity(Gravity.CENTER_VERTICAL);
        final android.widget.EditText name = defaultText(new android.widget.EditText(this));
        name.setSingleLine(true);
        name.setHint("File name");
        name.setText(fileName);
        row.addView(name, new LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f));
        final Spinner type = new Spinner(this);
        if (mode != 3 && !filterTexts.isEmpty()) {
            type.setAdapter(new ArrayAdapter<>(this, android.R.layout.simple_spinner_dropdown_item, filterTexts));
            type.setSelection(Math.max(0, Math.min(filterIndex - 1, filterTexts.size() - 1)));
            row.addView(type, new LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f));
        }
        if (mode != 3) layout.addView(row, new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT));
        // Select Folder: only the folders (a pattern which matches no file)
        final java.util.regex.Pattern noFiles = java.util.regex.Pattern.compile("(?!)");
        final Runnable fill = new Runnable() {
            @Override
            public void run() {
                java.util.regex.Pattern re = mode == 3 ? noFiles : filterPatterns.isEmpty() ? null : filterPatterns.get(Math.max(0, type.getSelectedItemPosition()));
                list.fill(current[0].getAbsolutePath(), re, mode == 1);
                current[0] = new java.io.File(list.folder());
            }
        };
        type.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                fill.run();
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {
            }
        });
        final android.widget.Button[] ok = new android.widget.Button[1];
        list.listener = new MffFileView.Listener() {
            @Override
            public void onChange(String event) {
                current[0] = new java.io.File(list.folder());
                ArrayList<String> files = list.chosen();
                if (event.equals("folder")) return;
                if (mode != 1 && !files.isEmpty()) name.setText(new java.io.File(files.get(0)).getName());
                if (event.equals("activate") && ok[0] != null) ok[0].performClick();
            }
        };

        android.app.AlertDialog.Builder builder = new android.app.AlertDialog.Builder(dialogOwner())
                .setTitle(caption.isEmpty() ? new String[] { "Open", "Open", "Save As", "Select Folder" }[mode] : caption)
                .setView(layout)
                .setPositiveButton(mode == 2 ? "Save" : "OK", null)
                .setNegativeButton("Cancel", null);
        if (mode >= 2) builder.setNeutralButton("New folder", null);
        final android.app.AlertDialog dialog = builder.create();
        // The keyboard of the file name: the dialog goes over it and the file list gets lower, else the file name is under the keyboard
        dialog.getWindow().setSoftInputMode(android.view.WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE);
        final View decor = dialog.getWindow().getDecorView();
        decor.getViewTreeObserver().addOnGlobalLayoutListener(new android.view.ViewTreeObserver.OnGlobalLayoutListener() {
            @Override
            public void onGlobalLayout() {
                android.graphics.Rect r = new android.graphics.Rect();
                decor.getWindowVisibleDisplayFrame(r);
                int h = Math.max(dp(60), Math.min(dp(300), r.height() - dp(270)));
                ViewGroup.LayoutParams lp = list.getLayoutParams();
                if (lp != null && lp.height != h) {
                    lp.height = h;
                    list.setLayoutParams(lp);
                }
            }
        });
        dialog.setOnShowListener(new android.content.DialogInterface.OnShowListener() {
            @Override
            public void onShow(android.content.DialogInterface d) {
                // The buttons do not close the dialog by themselves: the choice is checked first
                ok[0] = dialog.getButton(android.app.AlertDialog.BUTTON_POSITIVE);
                ok[0].setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        if (mode == 3) {
                            modalClose(dialog, current[0].getAbsolutePath());
                            return;
                        }
                        ArrayList<String> paths = new ArrayList<>();
                        if (mode == 1) paths.addAll(list.chosen());
                        String n = name.getText().toString();
                        if (mode == 2 && !n.isEmpty() && !filterExts.isEmpty()) {
                            int t = Math.max(0, type.getSelectedItemPosition());
                            java.io.File f = n.startsWith("/") ? new java.io.File(n) : new java.io.File(current[0], n);
                            if (!f.isDirectory() && !filterExts.get(t).isEmpty() && !filterPatterns.get(t).matcher(f.getName()).matches()) n += filterExts.get(t);
                        }
                        if (paths.isEmpty() && !n.isEmpty()) paths.add((n.startsWith("/") ? new java.io.File(n) : new java.io.File(current[0], n)).getAbsolutePath());
                        if (paths.isEmpty()) return;
                        if (paths.size() == 1 && new java.io.File(paths.get(0)).isDirectory()) {
                            current[0] = new java.io.File(paths.get(0));
                            name.setText("");
                            fill.run();
                            return;
                        }
                        if (mode != 2) {
                            for (String p : paths) {
                                if (!new java.io.File(p).exists()) {
                                    android.widget.Toast.makeText(mffActivity.this, "The file was not found.", android.widget.Toast.LENGTH_SHORT).show();
                                    return;
                                }
                            }
                        }
                        modalClose(dialog, android.text.TextUtils.join("\n", paths));
                    }
                });
                android.widget.Button newFolder = dialog.getButton(android.app.AlertDialog.BUTTON_NEUTRAL);
                if (newFolder != null) newFolder.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        String n = name.getText().toString();
                        if (mode == 3 || n.isEmpty()) return;
                        if (new java.io.File(current[0], n).mkdirs()) {
                            name.setText("");
                            fill.run();
                        }
                    }
                });
            }
        });
        fill.run();
        return modalShow(dialog);
    }

    // Style: 1 - bold, 2 - italic, 4 - underline, 8 - strikeout. Returns "Name\nSize\nStyle\nColor", null - cancelled
    public String fontDialog(String fontName, int size, int style, final int color) {
        LinearLayout layout = new LinearLayout(this);
        layout.setOrientation(LinearLayout.VERTICAL);
        layout.setPadding(dp(16), dp(8), dp(16), 0);
        final android.widget.EditText name = new android.widget.EditText(this);
        name.setSingleLine(true);
        name.setHint("Font name");
        name.setText(fontName);
        layout.addView(name);
        final android.widget.EditText sizeEdit = new android.widget.EditText(this);
        sizeEdit.setInputType(android.text.InputType.TYPE_CLASS_NUMBER);
        sizeEdit.setHint("Size");
        sizeEdit.setText(String.valueOf(size > 0 ? size : 10));
        layout.addView(sizeEdit);
        final android.widget.CheckBox[] checks = new android.widget.CheckBox[4];
        String[] texts = { "Bold", "Italic", "Underline", "Strikeout" };
        for (int i = 0; i < 4; i++) {
            checks[i] = new android.widget.CheckBox(this);
            checks[i].setText(texts[i]);
            checks[i].setChecked((style & (1 << i)) != 0);
            layout.addView(checks[i]);
        }
        final android.app.AlertDialog dialog = new android.app.AlertDialog.Builder(dialogOwner())
                .setTitle("Font")
                .setView(layout)
                .setPositiveButton("OK", null)
                .setNegativeButton("Cancel", null)
                .create();
        dialog.setOnShowListener(new android.content.DialogInterface.OnShowListener() {
            @Override
            public void onShow(android.content.DialogInterface d) {
                dialog.getButton(android.app.AlertDialog.BUTTON_POSITIVE).setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        int s = 0;
                        for (int i = 0; i < 4; i++) if (checks[i].isChecked()) s |= 1 << i;
                        modalClose(dialog, name.getText() + "\n" + sizeEdit.getText() + "\n" + s + "\n" + color);
                    }
                });
            }
        });
        return modalShow(dialog);
    }

    // Color is BGR (&hBBGGRR). Returns the chosen color, -1 - cancelled
    public int colorDialog(String caption, int color) {
        LinearLayout layout = new LinearLayout(this);
        layout.setOrientation(LinearLayout.VERTICAL);
        layout.setPadding(dp(16), dp(8), dp(16), 0);
        final View sample = new View(this);
        layout.addView(sample, new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, dp(48)));
        final SeekBar[] bars = new SeekBar[3];
        final int[] rgb = { color & 255, (color >> 8) & 255, (color >> 16) & 255 };
        for (int i = 0; i < 3; i++) {
            final int index = i;
            bars[i] = new SeekBar(this);
            bars[i].setMax(255);
            bars[i].setProgress(rgb[i]);
            bars[i].setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
                @Override
                public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                    rgb[index] = progress;
                    sample.setBackgroundColor(Color.rgb(rgb[0], rgb[1], rgb[2]));
                }

                @Override
                public void onStartTrackingTouch(SeekBar seekBar) {
                }

                @Override
                public void onStopTrackingTouch(SeekBar seekBar) {
                }
            });
            layout.addView(bars[i]);
        }
        sample.setBackgroundColor(Color.rgb(rgb[0], rgb[1], rgb[2]));
        final android.app.AlertDialog dialog = new android.app.AlertDialog.Builder(dialogOwner())
                .setTitle(caption.isEmpty() ? "Color" : caption)
                .setView(layout)
                .setPositiveButton("OK", null)
                .setNegativeButton("Cancel", null)
                .create();
        dialog.setOnShowListener(new android.content.DialogInterface.OnShowListener() {
            @Override
            public void onShow(android.content.DialogInterface d) {
                dialog.getButton(android.app.AlertDialog.BUTTON_POSITIVE).setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        modalClose(dialog, String.valueOf(rgb[0] | (rgb[1] << 8) | (rgb[2] << 16)));
                    }
                });
            }
        });
        String result = modalShow(dialog);
        return result == null ? -1 : Integer.parseInt(result);
    }

    // A popup menu (ShowPopupMenu of SysUtils.bas): items are the lines "Level\tEnabled\tChecked\tCaption", a submenu
    // is shown as the list of its items. Returns the index of the chosen line, -1 - the menu was closed
    public int popupMenu(String items, int x, int y) {
        final String[] lines = items.split("\n");
        int parent = -1;
        while (true) {
            // The items of the level under parent
            int level = parent < 0 ? 0 : Integer.parseInt(lines[parent].split("\t", 4)[0]) + 1;
            final ArrayList<Integer> indexes = new ArrayList<>();
            ArrayList<CharSequence> captions = new ArrayList<>();
            final ArrayList<Boolean> subs = new ArrayList<>();
            ArrayList<Boolean> checks = new ArrayList<>();
            boolean pictures = false;
            for (int i = parent + 1; i < lines.length; i++) {
                String[] p = lines[i].split("\t", 4);
                if (p.length < 4) continue;
                int l = Integer.parseInt(p[0]);
                if (l < level) break;
                if (l > level || p[3].equals("-")) continue;
                indexes.add(i);
                String caption = p[3].replaceAll("&(.)", "$1").split("\t")[0];
                boolean checked = p[2].equals("1");
                if (checked || caption.startsWith("\u0001")) pictures = true;
                captions.add(caption);
                checks.add(checked);
                subs.add(i + 1 < lines.length && lines[i + 1].startsWith((l + 1) + "\t"));
            }
            if (indexes.isEmpty()) return -1;
            // The column of the pictures like a menu of Windows: the check mark of a checked item is in it, the texts of
            // the items without a picture begin where the other ones begin (an empty picture)
            for (int i = 0; i < captions.size() && pictures; i++) {
                String caption = captions.get(i).toString();
                if (checks.get(i)) {
                    // a checked item with a picture keeps it in a frame (like a menu of Windows), else the check mark
                    if (caption.startsWith("\u0001") && caption.indexOf('\u0001', 1) > 0) caption = "\u0001:on:" + caption.substring(1);
                    else caption = "\u0001:check\u0001" + caption;
                } else if (!caption.startsWith("\u0001")) {
                    caption = "\u0001:blank\u0001" + caption;
                }
                captions.set(i, caption);
            }
            // the rows of the size of the default font with the picture of the item ("\u0001file\u0001" before the caption),
            // the arrow of an item with items at the right side
            ArrayAdapter<CharSequence> rows = new ArrayAdapter<CharSequence>(this, android.R.layout.simple_list_item_1, captions) {
                @Override
                public View getView(int position, View convertView, ViewGroup parent) {
                    View v = compactRow(super.getView(position, convertView, parent));
                    v.setPadding(dp(12), dp(7), dp(12), dp(7));
                    if (v instanceof TextView) ((TextView) v).setCompoundDrawablesWithIntrinsicBounds(null, null, subs.get(position) ? subMenuArrow() : null, null);
                    return v;
                }
            };
            final android.app.AlertDialog dialog = new android.app.AlertDialog.Builder(dialogOwner())
                    .setAdapter(rows, null)
                    .create();
            dialog.getListView().setOnItemClickListener(new AdapterView.OnItemClickListener() {
                @Override
                public void onItemClick(AdapterView<?> av, View view, int position, long id) {
                    String[] p = lines[indexes.get(position)].split("\t", 4);
                    if (!p[1].equals("1")) return;
                    modalClose(dialog, String.valueOf(indexes.get(position)));
                }
            });
            String result = modalShow(dialog);
            if (result == null) return -1;
            int chosen = Integer.parseInt(result);
            String[] p = lines[chosen].split("\t", 4);
            if (chosen + 1 < lines.length && lines[chosen + 1].startsWith((Integer.parseInt(p[0]) + 1) + "\t")) {
                parent = chosen;
                continue;
            }
            return chosen;
        }
    }

    // The text of the system clipboard (ClipboardSetText / ClipboardGetText of SysUtils.bas)
    public void clipboardSetText(String text) {
        android.content.ClipboardManager cm = (android.content.ClipboardManager) getSystemService(Context.CLIPBOARD_SERVICE);
        if (cm != null) cm.setPrimaryClip(android.content.ClipData.newPlainText("text", text));
    }

    public String clipboardGetText() {
        android.content.ClipboardManager cm = (android.content.ClipboardManager) getSystemService(Context.CLIPBOARD_SERVICE);
        if (cm == null || !cm.hasPrimaryClip() || cm.getPrimaryClip().getItemCount() == 0) return null;
        CharSequence s = cm.getPrimaryClip().getItemAt(0).coerceToText(this);
        return s == null ? null : s.toString();
    }

    public String viewGetText(View v) {
        if (v instanceof TextView) return ((TextView) v).getText().toString();
        return "";
    }

    // ---- Range controls: ProgressBar, SeekBar (TrackBar, ScrollBar), NumberPicker (NumericUpDown, UpDown)
    // ProgressBar.setMin and negative NumberPicker values are not available, so the minimum is an offset.
    private final HashMap<View, Integer> rangeMin = new HashMap<>();

    private int minOf(View v) {
        Integer m = rangeMin.get(v);
        return m == null ? 0 : m;
    }

    // UpDown, NumericUpDown: the number (it can be typed when the box is wide enough) and the arrows at the right side,
    // a narrow box (an UpDown next to its text box) is only the arrows. A held arrow repeats. A change by the user is
    // onListChange with the new value
    public static class MffSpinBox extends LinearLayout {
        private final mffActivity activity;
        private final android.widget.EditText edit;
        private int min = 0, max = 100, value = 0;
        private boolean setting;

        public MffSpinBox(mffActivity activity) {
            super(activity);
            this.activity = activity;
            setOrientation(HORIZONTAL);
            GradientDrawable border = new GradientDrawable();
            border.setColor(night(Color.WHITE, 0xFF1E1E1E));
            border.setStroke(Math.max(1, activity.dp(1)), 0xFF7A7A7A);
            setBackground(border);
            setPadding(1, 1, 1, 1);
            edit = activity.defaultText(new android.widget.EditText(activity));
            edit.setSingleLine(true);
            edit.setBackground(null);
            edit.setPadding(activity.dp(4), 0, activity.dp(2), 0);
            edit.setGravity(Gravity.CENTER_VERTICAL);
            edit.setInputType(android.text.InputType.TYPE_CLASS_NUMBER | android.text.InputType.TYPE_NUMBER_FLAG_SIGNED);
            edit.setImeOptions(android.view.inputmethod.EditorInfo.IME_ACTION_DONE | android.view.inputmethod.EditorInfo.IME_FLAG_NO_EXTRACT_UI);
            edit.addTextChangedListener(new android.text.TextWatcher() {
                @Override
                public void beforeTextChanged(CharSequence s, int start, int count, int after) {
                }

                @Override
                public void onTextChanged(CharSequence s, int start, int before, int count) {
                }

                @Override
                public void afterTextChanged(android.text.Editable s) {
                    if (setting) return;
                    try {
                        int v = Integer.parseInt(s.toString().trim());
                        if (v >= min && v <= max && v != value) {
                            value = v;
                            MffSpinBox.this.activity.onListChange(MffSpinBox.this, value);
                        }
                    } catch (NumberFormatException ignored) {
                    }
                }
            });
            // a number out of the range is the nearest one when the box loses the focus
            edit.setOnFocusChangeListener(new View.OnFocusChangeListener() {
                @Override
                public void onFocusChange(View view, boolean focused) {
                    if (!focused) show();
                }
            });
            addView(edit, new LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.MATCH_PARENT, 1f));
            LinearLayout arrows = new LinearLayout(activity);
            arrows.setOrientation(VERTICAL);
            arrows.addView(arrow(true), new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 0, 1f));
            arrows.addView(arrow(false), new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 0, 1f));
            addView(arrows, new LinearLayout.LayoutParams(activity.dp(16), ViewGroup.LayoutParams.MATCH_PARENT));
            show();
        }

        private View arrow(final boolean up) {
            final View a = new View(activity) {
                @Override
                protected void onDraw(android.graphics.Canvas c) {
                    super.onDraw(c);
                    android.graphics.Paint p = new android.graphics.Paint(android.graphics.Paint.ANTI_ALIAS_FLAG);
                    p.setColor(isEnabled() ? night(0xFF404040, 0xFFC8C8C8) : night(0xFFA0A0A0, 0xFF6D6D6D));
                    float w = getWidth(), h = getHeight(), s = Math.min(w, h) * 0.3f;
                    android.graphics.Path t = new android.graphics.Path();
                    if (up) {
                        t.moveTo(w / 2 - s, h / 2 + s / 2); t.lineTo(w / 2 + s, h / 2 + s / 2); t.lineTo(w / 2, h / 2 - s / 2);
                    } else {
                        t.moveTo(w / 2 - s, h / 2 - s / 2); t.lineTo(w / 2 + s, h / 2 - s / 2); t.lineTo(w / 2, h / 2 + s / 2);
                    }
                    t.close();
                    c.drawPath(t, p);
                }
            };
            android.graphics.drawable.StateListDrawable back = new android.graphics.drawable.StateListDrawable();
            back.addState(new int[]{android.R.attr.state_pressed}, new android.graphics.drawable.ColorDrawable(night(0xFFCCE4F7, 0xFF094771)));
            back.addState(new int[]{}, new android.graphics.drawable.ColorDrawable(night(0xFFF0F0F0, 0xFF333337)));
            a.setBackground(back);
            a.setClickable(true);
            // the first step at once, then the repeat while the arrow is held
            final Runnable repeat = new Runnable() {
                @Override
                public void run() {
                    step(up ? 1 : -1);
                    a.postDelayed(this, 80);
                }
            };
            a.setOnTouchListener(new View.OnTouchListener() {
                @Override
                public boolean onTouch(View view, android.view.MotionEvent e) {
                    switch (e.getActionMasked()) {
                        case android.view.MotionEvent.ACTION_DOWN:
                            a.setPressed(true);
                            step(up ? 1 : -1);
                            a.postDelayed(repeat, 400);
                            return true;
                        case android.view.MotionEvent.ACTION_UP:
                        case android.view.MotionEvent.ACTION_CANCEL:
                            a.setPressed(false);
                            a.removeCallbacks(repeat);
                            return true;
                    }
                    return true;
                }
            });
            return a;
        }

        private void step(int delta) {
            int v = Math.max(min, Math.min(max, value + delta));
            if (v == value) return;
            value = v;
            show();
            activity.onListChange(this, value);
        }

        private void show() {
            setting = true;
            String s = String.valueOf(value);
            if (!s.equals(edit.getText().toString())) edit.setText(s);
            setting = false;
        }

        // A narrow box (an UpDown next to its text box) is only the arrows
        @Override
        protected void onSizeChanged(int w, int h, int oldw, int oldh) {
            super.onSizeChanged(w, h, oldw, oldh);
            final boolean wide = w >= activity.dp(36);
            if ((edit.getVisibility() == View.VISIBLE) != wide) post(new Runnable() {
                @Override
                public void run() {
                    edit.setVisibility(wide ? View.VISIBLE : View.GONE);
                    View arrows = getChildAt(1);
                    arrows.setLayoutParams(wide ? new LinearLayout.LayoutParams(activity.dp(16), ViewGroup.LayoutParams.MATCH_PARENT)
                            : new LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.MATCH_PARENT, 1f));
                }
            });
        }

        @Override
        public void setEnabled(boolean enabled) {
            super.setEnabled(enabled);
            edit.setEnabled(enabled);
            View arrows = getChildAt(1);
            for (int i = 0; i < ((ViewGroup) arrows).getChildCount(); i++) {
                ((ViewGroup) arrows).getChildAt(i).setEnabled(enabled);
                ((ViewGroup) arrows).getChildAt(i).invalidate();
            }
        }

        void setRange(int min, int max) {
            this.min = Math.min(min, max);
            this.max = Math.max(min, max);
            setValue(value);
        }

        void setValue(int v) {
            value = Math.max(min, Math.min(max, v));
            show();
        }

        int getValue() {
            return value;
        }
    }

    public void rangeSet(View v, final int min, int max) {
        if (v instanceof MffSpinBox) {
            ((MffSpinBox) v).setRange(min, max);
            return;
        }
        int value = rangeGetValue(v);
        rangeMin.put(v, min);
        if (v instanceof ProgressBar) {
            ((ProgressBar) v).setMax(Math.max(0, max - min));
        } else if (v instanceof NumberPicker) {
            NumberPicker n = (NumberPicker) v;
            n.setMinValue(0);
            n.setMaxValue(Math.max(0, max - min));
            n.setFormatter(new NumberPicker.Formatter() {
                @Override
                public String format(int i) {
                    return String.valueOf(i + min);
                }
            });
        }
        rangeSetValue(v, value);
    }

    public void rangeSetValue(View v, int value) {
        // TabControl: the selected tab
        LinearLayout tabs = tabsBar(v);
        if (tabs != null) {
            tabsSelect(tabs, value);
            return;
        }
        if (v instanceof MffSpinBox) {
            ((MffSpinBox) v).setValue(value);
            return;
        }
        int min = minOf(v);
        if (v instanceof ProgressBar) ((ProgressBar) v).setProgress(Math.max(0, value - min));
        else if (v instanceof NumberPicker) ((NumberPicker) v).setValue(Math.max(0, value - min));
        else if (v instanceof DatePicker) {
            DatePicker d = (DatePicker) v;
            d.updateDate(value / 10000, (value / 100) % 100 - 1, value % 100);
        } else if (v instanceof android.widget.CalendarView) {
            java.util.Calendar cal = java.util.Calendar.getInstance();
            cal.set(value / 10000, (value / 100) % 100 - 1, value % 100, 0, 0, 0);
            ((android.widget.CalendarView) v).setDate(cal.getTimeInMillis(), false, true);
        }
    }

    public int rangeGetValue(View v) {
        if (v instanceof MffSpinBox) return ((MffSpinBox) v).getValue();
        int min = minOf(v);
        if (v instanceof ProgressBar) return ((ProgressBar) v).getProgress() + min;
        if (v instanceof NumberPicker) return ((NumberPicker) v).getValue() + min;
        if (v instanceof DatePicker) {
            DatePicker d = (DatePicker) v;
            return d.getYear() * 10000 + (d.getMonth() + 1) * 100 + d.getDayOfMonth();
        }
        if (v instanceof android.widget.CalendarView) {
            java.util.Calendar cal = java.util.Calendar.getInstance();
            cal.setTimeInMillis(((android.widget.CalendarView) v).getDate());
            return cal.get(java.util.Calendar.YEAR) * 10000 + (cal.get(java.util.Calendar.MONTH) + 1) * 100 + cal.get(java.util.Calendar.DAY_OF_MONTH);
        }
        return 0;
    }

    @Override
    public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
        if (fromUser) onListChange(seekBar, progress + minOf(seekBar));
    }

    @Override
    public void onStartTrackingTouch(SeekBar seekBar) {
    }

    @Override
    public void onStopTrackingTouch(SeekBar seekBar) {
    }

    @Override
    public void onValueChange(NumberPicker picker, int oldVal, int newVal) {
        onListChange(picker, newVal + minOf(picker));
    }

    // The height of the row of the tabs in pixels: the pages of the TabControl begin under it (SetMargins);
    // the width of the column of the tabs at the left and at the right
    public int tabsStripHeight() {
        return dp(32);
    }

    // TabPosition of a TabControl (tabsSetPosition): 0 - left, 1 - right (vertical tabs), 2 - top, 3 - bottom
    private final java.util.WeakHashMap<View, Integer> tabsPositions = new java.util.WeakHashMap<>();
    private final java.util.WeakHashMap<View, Boolean> tabsPlaced = new java.util.WeakHashMap<>();

    private int tabsPosition(View v) {
        Integer p = tabsPositions.get(v);
        return p == null ? 2 : p;
    }

    // A new position: the row of the tabs is made again by the next tabsSet (TabControl.UpdateTabs)
    public void tabsSetPosition(View v, int position) {
        if (position < 0 || position > 3) position = 2;
        if (tabsPosition(v) == position) return;
        tabsPositions.put(v, position);
        LinearLayout bar = tabsBar(v);
        if (bar != null) ((ViewGroup) v).removeView(bar);
    }

    // The row of the tabs at its side of the TabControl: AbsoluteLayout has no right and bottom alignment
    private void tabsPlaceBar(ViewGroup g, LinearLayout bar) {
        int pos = tabsPosition(g), size = tabsStripHeight();
        AbsoluteLayout.LayoutParams lp;
        if (pos == 0) lp = new AbsoluteLayout.LayoutParams(size, ViewGroup.LayoutParams.MATCH_PARENT, 0, 0);
        else if (pos == 1) lp = new AbsoluteLayout.LayoutParams(size, ViewGroup.LayoutParams.MATCH_PARENT, Math.max(0, g.getWidth() - size), 0);
        else if (pos == 3) lp = new AbsoluteLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, size, 0, Math.max(0, g.getHeight() - size));
        else lp = new AbsoluteLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, size, 0, 0);
        ViewGroup.LayoutParams old = bar.getLayoutParams();
        if (old instanceof AbsoluteLayout.LayoutParams) {
            AbsoluteLayout.LayoutParams o = (AbsoluteLayout.LayoutParams) old;
            if (o.x == lp.x && o.y == lp.y && o.width == lp.width && o.height == lp.height) return;
        }
        bar.setLayoutParams(lp);
    }

    // A tab of the tabs at the left and at the right: its row (the title, the picture and the close button) is turned
    // by 90 degrees like the vertical tabs of Windows (-90 - the text goes up, 90 - down); the touches go to the
    // turned row (the hit test of ViewGroup takes the rotation into account)
    public static class MffRotatedLayout extends ViewGroup {
        final int angle;

        public MffRotatedLayout(Context context, int angle) {
            super(context);
            this.angle = angle;
        }

        @Override
        protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
            View c = getChildAt(0);
            if (c == null) {
                setMeasuredDimension(0, 0);
                return;
            }
            c.measure(heightMeasureSpec, widthMeasureSpec);
            setMeasuredDimension(c.getMeasuredHeight(), c.getMeasuredWidth());
        }

        @Override
        protected void onLayout(boolean changed, int l, int t, int r, int b) {
            View c = getChildAt(0);
            if (c == null) return;
            int cw = c.getMeasuredWidth(), ch = c.getMeasuredHeight();
            int x = (r - l - cw) / 2, y = (b - t - ch) / 2;
            c.layout(x, y, x + cw, y + ch);
            c.setPivotX(cw / 2f);
            c.setPivotY(ch / 2f);
            c.setRotation(angle);
        }
    }

    // The scrolling of the tabs: a HorizontalScrollView, a ScrollView for the vertical tabs
    private static void tabsScrollBy(View scroll, int delta) {
        if (scroll instanceof ScrollView) ((ScrollView) scroll).smoothScrollBy(0, delta);
        else if (scroll instanceof HorizontalScrollView) ((HorizontalScrollView) scroll).smoothScrollBy(delta, 0);
    }

    private Button tabsScrollButton(String text, final android.widget.FrameLayout hs, final int direction) {
        Button b = defaultText(new Button(this));
        b.setText(text);
        b.setMinHeight(0);
        b.setMinimumHeight(0);
        b.setMinWidth(0);
        b.setMinimumWidth(0);
        b.setBackground(flatButtonBackground(night(0xFFE4E4E4, 0xFF3C3C3C)));
        b.setStateListAnimator(null);
        b.setTextColor(textColor());
        b.setPadding(dp(6), 0, dp(6), 0);
        b.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                tabsScrollBy(hs, direction * Math.max(dp(48), (hs instanceof ScrollView ? hs.getHeight() : hs.getWidth()) / 2));
            }
        });
        return b;
    }

    // The row of the tabs of a TabControl: a child of the view itself, not of a TabControl on one of its pages
    private static LinearLayout tabsBar(View v) {
        if (!(v instanceof ViewGroup)) return null;
        ViewGroup g = (ViewGroup) v;
        for (int i = 0; i < g.getChildCount(); i++) {
            View c = g.getChildAt(i);
            if ("mffTabs".equals(c.getTag()) && c instanceof LinearLayout) return (LinearLayout) c;
        }
        return null;
    }

    // The background of a flat button (toolbars, the buttons < > of the tabs) like the ones of Windows: the button of
    // the theme has insets around it (wider buttons, gaps) and is dark in the night mode. normal - the color of the
    // button which is not pressed (0 - none, the buttons of a toolbar)
    private android.graphics.drawable.Drawable flatButtonBackground(int normal) {
        GradientDrawable pressed = new GradientDrawable();
        pressed.setColor(night(0xFFC8C8C8, 0xFF505055));
        GradientDrawable checked = new GradientDrawable();
        checked.setColor(night(0xFFCCE4F7, 0xFF094771));
        checked.setStroke(Math.max(1, dp(1) / 2), night(0xFF99C9EF, 0xFF1C6BB0));
        android.graphics.drawable.StateListDrawable d = new android.graphics.drawable.StateListDrawable();
        d.addState(new int[]{android.R.attr.state_pressed}, pressed);
        d.addState(new int[]{android.R.attr.state_selected}, checked);
        if (normal != 0) {
            GradientDrawable n = new GradientDrawable();
            n.setColor(normal);
            n.setStroke(Math.max(1, dp(1) / 2), night(0xFFC0C0C0, 0xFF555555));
            d.addState(new int[]{}, n);
        }
        return d;
    }

    // The background of a tab: the selected one is light with a line at the outer side (at the top; at the bottom for
    // the tabs at the bottom; the vertical tabs are turned with it), the others are gray
    private android.graphics.drawable.Drawable tabBackground(boolean bottom) {
        GradientDrawable line = new GradientDrawable();
        line.setColor(0xFF1E88E5);
        GradientDrawable selectedFill = new GradientDrawable();
        selectedFill.setColor(night(Color.WHITE, 0xFF1E1E1E));
        android.graphics.drawable.LayerDrawable selected = new android.graphics.drawable.LayerDrawable(
                new android.graphics.drawable.Drawable[]{selectedFill, line});
        if (bottom) selected.setLayerInset(1, 0, tabsStripHeight() - dp(3), 0, 0);
        else selected.setLayerInset(1, 0, 0, 0, tabsStripHeight() - dp(3));
        GradientDrawable pressed = new GradientDrawable();
        pressed.setColor(night(0xFFC8C8C8, 0xFF505055));
        GradientDrawable normal = new GradientDrawable();
        normal.setColor(night(0xFFE4E4E4, 0xFF2D2D30));
        normal.setStroke(Math.max(1, dp(1) / 2), night(0xFFC0C0C0, 0xFF3F3F46));
        android.graphics.drawable.StateListDrawable d = new android.graphics.drawable.StateListDrawable();
        d.addState(new int[]{android.R.attr.state_selected}, selected);
        d.addState(new int[]{android.R.attr.state_pressed}, pressed);
        d.addState(new int[]{}, normal);
        return d;
    }

    // The selected tab of a TabControl (SetPosition) is shown selected and is scrolled into the view
    private void tabsSelect(LinearLayout bar, int index) {
        final android.widget.FrameLayout scroll = bar.findViewWithTag("mffTabsScroll");
        final LinearLayout strip = (LinearLayout) scroll.getChildAt(0);
        View selected = null;
        for (int i = 0; i < strip.getChildCount(); i++) {
            View tab = strip.getChildAt(i);
            boolean isSelected = i == index;
            tab.setSelected(isSelected);
            // the row of a vertical tab is in its MffRotatedLayout
            View row = tab instanceof MffRotatedLayout ? ((ViewGroup) tab).getChildAt(0) : tab;
            View title = ((ViewGroup) row).getChildAt(0);
            if (title instanceof TextView) ((TextView) title).setTypeface(null, isSelected ? android.graphics.Typeface.BOLD : android.graphics.Typeface.NORMAL);
            if (isSelected) selected = tab;
        }
        if (selected != null) {
            final View tab = selected;
            scroll.post(new Runnable() {
                @Override
                public void run() {
                    if (scroll instanceof ScrollView) {
                        ScrollView sv = (ScrollView) scroll;
                        if (tab.getTop() < sv.getScrollY()) sv.smoothScrollTo(0, tab.getTop());
                        else if (tab.getBottom() > sv.getScrollY() + sv.getHeight()) sv.smoothScrollTo(0, tab.getBottom() - sv.getHeight());
                    } else {
                        HorizontalScrollView hs = (HorizontalScrollView) scroll;
                        if (tab.getLeft() < hs.getScrollX()) hs.smoothScrollTo(tab.getLeft(), 0);
                        else if (tab.getRight() > hs.getScrollX() + hs.getWidth()) hs.smoothScrollTo(tab.getRight() - hs.getWidth(), 0);
                    }
                }
            });
        }
    }

    // ---- TabControl: an AbsoluteLayout with a row of buttons at its side (TabPosition); the pages are its children.
    // A title is "Caption\tx\tPicture": "x" - a close button (its tap is the index -1 - Index, OnTabClose),
    // Picture - the picture file of the tab (FindResourceFile)
    public void tabsSet(View v, String titles) {
        if (!(v instanceof ViewGroup)) return;
        final ViewGroup g = (ViewGroup) v;
        final int pos = tabsPosition(g);
        final boolean vertical = pos == 0 || pos == 1;
        // The row of the tabs: the tabs scroll, the buttons < > (^ v for the vertical tabs) scroll them when they do not fit
        LinearLayout bar = tabsBar(g);
        if (bar == null) {
            bar = new LinearLayout(this);
            bar.setTag("mffTabs");
            bar.setOrientation(vertical ? LinearLayout.VERTICAL : LinearLayout.HORIZONTAL);
            final android.widget.FrameLayout hs;
            LinearLayout strip = new LinearLayout(this);
            if (vertical) {
                ScrollView sv = new ScrollView(this);
                sv.setVerticalScrollBarEnabled(false);
                strip.setOrientation(LinearLayout.VERTICAL);
                hs = sv;
            } else {
                HorizontalScrollView h = new HorizontalScrollView(this);
                h.setHorizontalScrollBarEnabled(false);
                hs = h;
            }
            hs.setTag("mffTabsScroll");
            hs.addView(strip);
            if (vertical) bar.addView(hs, new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 0, 1f));
            else bar.addView(hs, new LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f));
            final Button left = tabsScrollButton(vertical ? "\u25B2" : "\u25C0", hs, -1);
            final Button right = tabsScrollButton(vertical ? "\u25BC" : "\u25B6", hs, 1);
            LinearLayout.LayoutParams arrow = vertical
                    ? new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT)
                    : new LinearLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.MATCH_PARENT);
            bar.addView(left, arrow);
            bar.addView(right, new LinearLayout.LayoutParams(arrow));
            hs.addOnLayoutChangeListener(new View.OnLayoutChangeListener() {
                @Override
                public void onLayoutChange(View view, int l, int t, int r, int b, int ol, int ot, int or, int ob) {
                    boolean shown = left.getVisibility() == View.VISIBLE;
                    boolean overflow = vertical
                            ? hs.getChildAt(0).getHeight() > hs.getHeight() + (shown ? left.getHeight() + right.getHeight() : 0)
                            : hs.getChildAt(0).getWidth() > hs.getWidth() + (shown ? left.getWidth() + right.getWidth() : 0);
                    final int visibility = overflow ? View.VISIBLE : View.GONE;
                    if (left.getVisibility() != visibility) {
                        hs.post(new Runnable() {
                            @Override
                            public void run() {
                                left.setVisibility(visibility);
                                right.setVisibility(visibility);
                            }
                        });
                    }
                }
            });
            left.setVisibility(View.GONE);
            right.setVisibility(View.GONE);
            g.addView(bar, new AbsoluteLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, tabsStripHeight(), 0, 0));
            tabsPlaceBar(g, bar);
            // At the right and at the bottom the row follows the size of the TabControl
            if (tabsPlaced.get(g) == null) {
                tabsPlaced.put(g, Boolean.TRUE);
                g.addOnLayoutChangeListener(new View.OnLayoutChangeListener() {
                    @Override
                    public void onLayoutChange(View view, int l, int t, int r, int b, int ol, int ot, int or, int ob) {
                        if (r - l == or - ol && b - t == ob - ot) return;
                        g.post(new Runnable() {
                            @Override
                            public void run() {
                                LinearLayout current = tabsBar(g);
                                if (current != null) tabsPlaceBar(g, current);
                            }
                        });
                    }
                });
            }
        }
        android.widget.FrameLayout scroll = bar.findViewWithTag("mffTabsScroll");
        LinearLayout strip = (LinearLayout) scroll.getChildAt(0);
        strip.removeAllViews();
        if (titles == null || titles.isEmpty()) return;
        String[] list = titles.split("\n");
        for (int i = 0; i < list.length; i++) {
            String[] parts = list[i].split("\t", -1);
            String title = parts[0];
            // the tab: the title and the close button on the background of the tab
            LinearLayout tab = new LinearLayout(this);
            tab.setBackground(tabBackground(pos == 3));
            tab.setGravity(Gravity.CENTER_VERTICAL);
            Button b = defaultText(new Button(this));
            b.setText(title);
            b.setTextColor(textColor());
            b.setAllCaps(false);
            b.setMinHeight(0);
            b.setMinimumHeight(0);
            b.setMinWidth(0);
            b.setMinimumWidth(0);
            b.setBackground(null);
            b.setStateListAnimator(null);
            b.setPadding(dp(8), dp(4), dp(4), dp(4));
            android.graphics.drawable.Drawable picture = parts.length > 2 ? buttonPicture(parts[2]) : null;
            if (picture != null) {
                picture.setBounds(0, 0, dp(16), dp(16));
                b.setCompoundDrawables(picture, null, null, null);
                b.setCompoundDrawablePadding(dp(4));
            }
            final int index = i;
            b.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    onListChange(g, index);
                }
            });
            tab.addView(b, new LinearLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.MATCH_PARENT));
            if (vertical) {
                // the line of the selected tab at the outer side: the top of the row is turned to the left or to the right
                MffRotatedLayout turned = new MffRotatedLayout(this, pos == 0 ? -90 : 90);
                turned.addView(tab, new ViewGroup.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, tabsStripHeight()));
                strip.addView(turned, new LinearLayout.LayoutParams(tabsStripHeight(), ViewGroup.LayoutParams.WRAP_CONTENT));
            } else {
                strip.addView(tab, new LinearLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, tabsStripHeight()));
            }
            if (parts.length > 1 && !parts[1].isEmpty()) {
                Button close = defaultText(new Button(this));
                close.setText("\u00D7");
                close.setTextColor(textColor());
                close.setAllCaps(false);
                close.setMinHeight(0);
                close.setMinimumHeight(0);
                close.setMinWidth(0);
                close.setMinimumWidth(0);
                close.setBackground(null);
                close.setStateListAnimator(null);
                close.setPadding(dp(4), dp(4), dp(8), dp(4));
                close.setContentDescription("Close " + title);
                close.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View view) {
                        onListChange(g, -1 - index);
                    }
                });
                tab.addView(close, new LinearLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.MATCH_PARENT));
            }
        }
    }

    // ---- TimerComponent: id is the address of the TimerComponent
    private final android.os.Handler timerHandler = new android.os.Handler(android.os.Looper.getMainLooper());
    private final HashMap<Long, Runnable> timers = new HashMap<>();

    public void timerStart(final long id, final int interval) {
        timerStop(id);
        Runnable r = new Runnable() {
            @Override
            public void run() {
                if (timers.get(id) != this) return;
                onTimer(id);
                if (timers.get(id) == this) timerHandler.postDelayed(this, Math.max(1, interval));
            }
        };
        timers.put(id, r);
        timerHandler.postDelayed(r, Math.max(1, interval));
    }

    public void timerStop(long id) {
        Runnable r = timers.remove(id);
        if (r != null) timerHandler.removeCallbacks(r);
    }

    /**
     * Implemented by the native library (TimerComponent.bas): the interval of a TimerComponent elapsed.
     */
    public native void onTimer(long id);

    // ---- ImageBox, Picture: a picture file (or an asset of the application) in an ImageView or as the background
    @SuppressWarnings("deprecation")
    public void imageLoad(View v, String path, boolean center) {
        android.graphics.Bitmap b = null;
        if (path != null && !path.isEmpty()) {
            b = android.graphics.BitmapFactory.decodeFile(path);
            if (b == null) {
                java.io.InputStream in = null;
                try {
                    String asset = path.replace(java.io.File.separatorChar, '/').replace("\\", "/");
                    if (asset.startsWith("./")) asset = asset.substring(2);
                    in = getAssets().open(asset);
                    b = android.graphics.BitmapFactory.decodeStream(in);
                } catch (Exception ex) {
                    Log.println(Log.WARN, "mff", "imageLoad: " + ex.getMessage());
                } finally {
                    try {
                        if (in != null) in.close();
                    } catch (Exception ignored) {
                    }
                }
            }
        }
        if (v instanceof ImageView) {
            ImageView iv = (ImageView) v;
            iv.setScaleType(center ? ImageView.ScaleType.CENTER : ImageView.ScaleType.FIT_XY);
            iv.setImageBitmap(b);
        } else {
            v.setBackgroundDrawable(b == null ? null : new android.graphics.drawable.BitmapDrawable(getResources(), b));
        }
    }

    // ---- ToolBar: a row of buttons in the layout; the first char of an item is a flag:
    // '0' - button, '1' - disabled, '2' - checked, '3' - separator, '4' - hidden;
    // a first item '5' (ToolPalette) shows the buttons in a column which scrolls vertically;
    // a picture file after '\t' (FindResourceFile) is shown on the button: a row shows only the picture
    private final HashMap<String, android.graphics.Bitmap> buttonPictures = new HashMap<>();

    private android.graphics.drawable.Drawable buttonPicture(String file) {
        if (file == null || file.isEmpty()) return null;
        android.graphics.Bitmap bitmap = buttonPictures.get(file);
        if (bitmap == null && !buttonPictures.containsKey(file)) {
            bitmap = android.graphics.BitmapFactory.decodeFile(file);
            buttonPictures.put(file, bitmap);
        }
        if (bitmap == null) return null;
        android.graphics.drawable.BitmapDrawable d = new android.graphics.drawable.BitmapDrawable(getResources(), bitmap);
        d.setBounds(0, 0, dp(20), dp(20));
        return d;
    }

    // The arrow (a small triangle) of a button of a ToolBar with a drop-down menu
    private android.graphics.drawable.Drawable menuArrow() {
        int w = dp(8), h = dp(5);
        android.graphics.Bitmap b = android.graphics.Bitmap.createBitmap(w, h, android.graphics.Bitmap.Config.ARGB_8888);
        android.graphics.Canvas c = new android.graphics.Canvas(b);
        android.graphics.Paint p = new android.graphics.Paint(android.graphics.Paint.ANTI_ALIAS_FLAG);
        p.setColor(night(0xFF404040, 0xFFC8C8C8));
        android.graphics.Path t = new android.graphics.Path();
        t.moveTo(0, 0);
        t.lineTo(w, 0);
        t.lineTo(w / 2f, h);
        t.close();
        c.drawPath(t, p);
        android.graphics.drawable.BitmapDrawable d = new android.graphics.drawable.BitmapDrawable(getResources(), b);
        d.setBounds(0, 0, w, h);
        return d;
    }

    // The arrow of an item of a menu with items (at the right side of the row)
    private android.graphics.drawable.Drawable subMenuArrow() {
        int w = dp(6), h = dp(10);
        android.graphics.Bitmap b = android.graphics.Bitmap.createBitmap(w, h, android.graphics.Bitmap.Config.ARGB_8888);
        android.graphics.Canvas c = new android.graphics.Canvas(b);
        android.graphics.Paint p = new android.graphics.Paint(android.graphics.Paint.ANTI_ALIAS_FLAG);
        p.setColor(night(0xFF404040, 0xFFC8C8C8));
        android.graphics.Path t = new android.graphics.Path();
        t.moveTo(0, 0);
        t.lineTo(w, h / 2f);
        t.lineTo(0, h);
        t.close();
        c.drawPath(t, p);
        return new android.graphics.drawable.BitmapDrawable(getResources(), b);
    }

    // The picture of a checked item of a menu in a frame (":on:file" of popupMenu); without the picture the check mark
    private android.graphics.drawable.Drawable checkedPicture(android.graphics.drawable.Drawable picture) {
        if (picture == null) return checkMark();
        GradientDrawable frame = new GradientDrawable();
        frame.setColor(night(0xFFCCE4F7, 0xFF094771));
        frame.setStroke(Math.max(1, dp(1)), 0xFF5B9BD5);
        frame.setCornerRadius(dp(2));
        android.graphics.drawable.LayerDrawable layers = new android.graphics.drawable.LayerDrawable(new android.graphics.drawable.Drawable[]{frame, picture});
        int inset = dp(2);
        layers.setLayerInset(1, inset, inset, inset, inset);
        return layers;
    }

    // The check mark of a checked item of a menu (in the column of the pictures)
    private android.graphics.drawable.Drawable checkMark() {
        int s = dp(20);
        android.graphics.Bitmap b = android.graphics.Bitmap.createBitmap(s, s, android.graphics.Bitmap.Config.ARGB_8888);
        android.graphics.Canvas c = new android.graphics.Canvas(b);
        android.graphics.Paint p = new android.graphics.Paint(android.graphics.Paint.ANTI_ALIAS_FLAG);
        p.setColor(night(0xFF202020, 0xFFE0E0E0));
        p.setStyle(android.graphics.Paint.Style.STROKE);
        p.setStrokeWidth(s / 9f);
        p.setStrokeCap(android.graphics.Paint.Cap.ROUND);
        p.setStrokeJoin(android.graphics.Paint.Join.ROUND);
        android.graphics.Path t = new android.graphics.Path();
        t.moveTo(s * 0.22f, s * 0.52f);
        t.lineTo(s * 0.42f, s * 0.72f);
        t.lineTo(s * 0.78f, s * 0.3f);
        c.drawPath(t, p);
        return new android.graphics.drawable.BitmapDrawable(getResources(), b);
    }

    // The items of buttonsSet of a view and the views which follow their size (a column when they are tall)
    private final HashMap<View, String> buttonsItems = new HashMap<>();
    private final HashSet<View> buttonsFollowed = new HashSet<>();

    public void buttonsSet(View v, String items) {
        if (!(v instanceof ViewGroup)) return;
        final ViewGroup g = (ViewGroup) v;
        buttonsItems.put(g, items);
        if (buttonsFollowed.add(g)) {
            g.addOnLayoutChangeListener(new View.OnLayoutChangeListener() {
                @Override
                public void onLayoutChange(View view, int l, int t, int r, int b, int ol, int ot, int or, int ob) {
                    final String last = buttonsItems.get(g);
                    if (last == null || last.startsWith("5")) return;
                    android.widget.FrameLayout scroll = g.findViewWithTag("mffButtons");
                    boolean tall = b - t > (r - l) * 3 / 2;
                    if (scroll != null && (scroll instanceof ScrollView) != tall) {
                        g.post(new Runnable() {
                            @Override
                            public void run() {
                                buttonsSet(g, buttonsItems.get(g));
                            }
                        });
                    } else if (scroll instanceof HorizontalScrollView) {
                        // another width: the buttons of the overflow menu again (nothing when the width is the same)
                        Integer lastWidth = buttonsWidths.get(g);
                        if (lastWidth == null || lastWidth != r - l - g.getPaddingLeft() - g.getPaddingRight()) g.post(new Runnable() {
                            @Override
                            public void run() {
                                buttonsOverflow(g);
                            }
                        });
                    }
                }
            });
        }
        String[] list = items == null || items.isEmpty() ? new String[0] : items.split("\n");
        // a tall view shows the buttons in a column too
        ViewGroup.LayoutParams lp = g.getLayoutParams();
        final int first = list.length > 0 && list[0].startsWith("5") ? 1 : 0;
        final boolean column = first == 1 || (g.getWidth() > 0 ? g.getHeight() > g.getWidth() * 3 / 2 : lp != null && lp.height > lp.width * 3 / 2);
        android.widget.FrameLayout scroll = g.findViewWithTag("mffButtons");
        if (scroll != null && (scroll instanceof ScrollView) != column) {
            g.removeView(scroll);
            scroll = null;
        }
        if (scroll == null) {
            if (column) {
                scroll = new ScrollView(this);
            } else {
                scroll = new HorizontalScrollView(this);
                scroll.setHorizontalScrollBarEnabled(false);
            }
            scroll.setTag("mffButtons");
            scroll.addView(new LinearLayout(this));
            // under the controls of the custom buttons (they are children of the toolbar too)
            g.addView(scroll, 0, new AbsoluteLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT, 0, 0));
            if (Build.VERSION.SDK_INT >= 23 && !column) {
                // the controls of the custom buttons follow the scrolled buttons (CM_SIZE of the toolbar)
                scroll.setOnScrollChangeListener(new View.OnScrollChangeListener() {
                    @Override
                    public void onScrollChange(View view, int x, int y, int ox, int oy) {
                        onLayoutChange(g, g.getLeft(), g.getTop(), g.getRight(), g.getBottom(), g.getLeft(), g.getTop(), g.getRight(), g.getBottom());
                    }
                });
            }
        }
        LinearLayout row = (LinearLayout) scroll.getChildAt(0);
        row.removeAllViews();
        row.setOrientation(column ? LinearLayout.VERTICAL : LinearLayout.HORIZONTAL);
        // a row of buttons has the height of the toolbar and its buttons are in the middle of it: the toolbars of a
        // ReBar row are on one line (the buttons with a text are lower than the ones with a picture)
        row.setLayoutParams(new android.widget.FrameLayout.LayoutParams(column ? ViewGroup.LayoutParams.MATCH_PARENT : ViewGroup.LayoutParams.WRAP_CONTENT,
                column ? ViewGroup.LayoutParams.WRAP_CONTENT : ViewGroup.LayoutParams.MATCH_PARENT));
        row.setGravity(column ? Gravity.START | Gravity.TOP : Gravity.START | Gravity.CENTER_VERTICAL);
        boolean hasGaps = false, expands = false;
        final boolean narrow = (g.getWidth() > 0 ? g.getWidth() : lp != null ? lp.width : 0) < dp(96);
        for (int i = first; i < list.length; i++) {
            char flag = list[i].isEmpty() ? '0' : list[i].charAt(0);
            String text = list[i].length() > 1 ? list[i].substring(1) : "";
            android.graphics.drawable.Drawable picture = null;
            // "Text\tPicture\tOptions": S - the caption is shown by the picture, D - the arrow of the drop-down menu,
            // W - the whole button opens the menu (ToolBar.UpdateButtons)
            String options = "", file = "";
            int tab = text.indexOf('\t');
            if (tab >= 0) {
                file = text.substring(tab + 1);
                int tab2 = file.indexOf('\t');
                if (tab2 >= 0) {
                    options = file.substring(tab2 + 1);
                    file = file.substring(0, tab2);
                }
                picture = buttonPicture(file);
                text = text.substring(0, tab);
            }
            boolean caption = options.indexOf('S') >= 0, menu = options.indexOf('W') >= 0 || options.indexOf('D') >= 0;
            View item;
            if (flag == '6' || flag == '7') {
                // the gap of the control of a custom button; 7 - it takes the free width of the bar (Expand)
                int width = 0;
                try {
                    width = Integer.parseInt(text.trim());
                } catch (NumberFormatException e) {
                    // no width
                }
                View gap = new View(this);
                // the overflow menu does not take the buttons before it (the control stays over its gap)
                gap.setTag("mffGap");
                row.addView(gap, new LinearLayout.LayoutParams(width, ViewGroup.LayoutParams.MATCH_PARENT, flag == '7' ? 1f : 0f));
                if (flag == '7') expands = true;
                hasGaps = true;
                continue;
            }
            if (flag == '3') {
                item = new View(this);
                item.setBackgroundColor(Color.GRAY);
                row.addView(item, column ? new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, Math.max(1, dp(1)))
                        : new LinearLayout.LayoutParams(Math.max(1, dp(1)), ViewGroup.LayoutParams.MATCH_PARENT));
                continue;
            }
            Button b = defaultText(new Button(this));
            b.setText(text);
            b.setTextColor(textColor());
            b.setAllCaps(false);
            b.setMinHeight(0);
            b.setMinimumHeight(0);
            b.setMinWidth(0);
            b.setMinimumWidth(0);
            // flat like a toolbar of Windows: the button of the theme is wider (insets) and dark in the night mode
            b.setBackground(flatButtonBackground(0));
            b.setStateListAnimator(null);
            b.setPadding(dp(8), dp(2), dp(8), dp(2));
            // the arrow of a button with a drop-down menu at its right side
            android.graphics.drawable.Drawable arrow = menu ? menuArrow() : null;
            if (picture != null || arrow != null) {
                b.setCompoundDrawables(picture, null, arrow, null);
                b.setCompoundDrawablePadding(dp(picture != null && arrow != null && !caption ? 2 : 6));
                // a row, or a narrow column (the vertical toolbar of a panel), shows only the picture; a button with a
                // caption (like a toolbar with labels of Windows) shows it by the picture
                if (picture != null && (!column || narrow) && !(caption && !narrow)) {
                    b.setContentDescription(text);
                    b.setText("");
                    // the padding of the drawables is added also without a text: space at the right of the picture
                    b.setCompoundDrawablePadding(arrow != null ? dp(2) : 0);
                    b.setPadding(dp(4), dp(4), dp(4), dp(4));
                } else if (picture != null && !column) {
                    b.setPadding(dp(4), dp(2), dp(6), dp(2));
                }
            }
            b.setEnabled(flag != '1');
            b.setAlpha(flag == '1' ? 0.4f : 1f);
            b.setSelected(flag == '2');
            if (flag == '4') b.setVisibility(View.GONE);
            final int index = i - first;
            // the index and the item of popupMenu of the button in the overflow menu (buttonsOverflow)
            b.setTag(new Object[]{index, "0\t" + (flag == '1' ? "0" : "1") + "\t" + (flag == '2' ? "1" : "0") + "\t"
                    + (picture != null ? "\u0001" + file + "\u0001" : "") + text});
            // a drop-down button (D): a tap on its arrow (at the right side) shows the menu, index | &h10000
            final boolean split = options.indexOf('D') >= 0;
            final float[] touchX = {-1};
            if (split) b.setOnTouchListener(new View.OnTouchListener() {
                @Override
                public boolean onTouch(View view, android.view.MotionEvent e) {
                    if (e.getActionMasked() == android.view.MotionEvent.ACTION_DOWN) touchX[0] = e.getX();
                    return false;
                }
            });
            b.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    boolean onArrow = split && touchX[0] >= view.getWidth() - view.getPaddingRight() - dp(8) - dp(6);
                    onListChange(g, onArrow ? index | 0x10000 : index);
                }
            });
            if (column) {
                b.setGravity(Gravity.START | Gravity.CENTER_VERTICAL);
                row.addView(b, new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT));
            } else {
                row.addView(b);
            }
        }
        // the expanded gaps share the free width of the bar (the row fills it), their controls follow their widths
        if (scroll instanceof HorizontalScrollView) ((HorizontalScrollView) scroll).setFillViewport(expands);
        if (expands && row.getTag() == null) {
            row.setTag("mffExpands");
            row.addOnLayoutChangeListener(new View.OnLayoutChangeListener() {
                @Override
                public void onLayoutChange(View view, int l, int t, int r, int b, int ol, int ot, int or, int ob) {
                    if (r - l == or - ol) return;
                    g.post(new Runnable() {
                        @Override
                        public void run() {
                            mffActivity.this.onLayoutChange(g, g.getLeft(), g.getTop(), g.getRight(), g.getBottom(), g.getLeft(), g.getTop(), g.getRight(), g.getBottom());
                        }
                    });
                }
            });
        }
        if (hasGaps) {
            row.post(new Runnable() {
                @Override
                public void run() {
                    onLayoutChange(g, g.getLeft(), g.getTop(), g.getRight(), g.getBottom(), g.getLeft(), g.getTop(), g.getRight(), g.getBottom());
                }
            });
        }
        if (!column) {
            buttonsWidths.remove(g);
            row.post(new Runnable() {
                @Override
                public void run() {
                    buttonsOverflow(g);
                }
            });
        }
    }

    // The overflow menu of a row of buttons: the buttons at the end which do not fit are hidden, the button "⋮" shows
    // them in a menu (popupMenu) like the overflow menu of the action bar. The gap of a custom button (a control over it)
    // and the buttons before it stay. The width of all the buttons (buttonsContentWidth) and of the view of the last time
    private final HashMap<View, Integer> buttonsFullWidths = new HashMap<>();
    private final HashMap<View, Integer> buttonsWidths = new HashMap<>();

    private void buttonsOverflow(final ViewGroup g) {
        android.widget.FrameLayout scroll = g.findViewWithTag("mffButtons");
        if (!(scroll instanceof HorizontalScrollView) || !(scroll.getChildAt(0) instanceof LinearLayout)) return;
        int available = g.getWidth() - g.getPaddingLeft() - g.getPaddingRight();
        if (available <= 0) return;
        Integer last = buttonsWidths.get(g);
        if (last != null && last == available) return;
        buttonsWidths.put(g, available);
        LinearLayout row = (LinearLayout) scroll.getChildAt(0);
        View old = row.findViewWithTag("mffOverflow");
        if (old != null) row.removeView(old);
        for (int c = 0; c < row.getChildCount(); c++) {
            View child = row.getChildAt(c);
            if (buttonsOverflowed.remove(child)) child.setVisibility(View.VISIBLE);
        }
        for (int c = 0; c < g.getChildCount(); c++) {
            View child = g.getChildAt(c);
            if (buttonsOverflowed.remove(child)) child.setVisibility(View.VISIBLE);
        }
        int unspecified = View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED);
        row.measure(unspecified, unspecified);
        int width = row.getMeasuredWidth();
        // the lefts of the items in the row (the controls of the custom buttons are over their gaps: ToolBar CM_SIZE)
        int[] lefts = new int[row.getChildCount()];
        for (int c = 0, x = 0; c < row.getChildCount(); c++) {
            lefts[c] = x;
            if (row.getChildAt(c).getVisibility() != View.GONE) x += row.getChildAt(c).getMeasuredWidth();
        }
        Integer oldWidth = buttonsFullWidths.put(g, width);
        if (width <= available) return;
        // the width of all the buttons is known now (buttonsContentWidth): the ReBar of the toolbar gives its band that
        // width when there is the place (the band got the width before the last buttons, they were in the menu)
        if (oldWidth == null || oldWidth != width) {
            final View p = g.getParent() instanceof View ? (View) g.getParent() : null;
            if (p != null) p.post(new Runnable() {
                @Override
                public void run() {
                    onLayoutChange(p, p.getLeft(), p.getTop(), p.getRight(), p.getBottom(), p.getLeft(), p.getTop(), p.getRight(), p.getBottom());
                }
            });
        }
        Button more = defaultText(new Button(this));
        more.setTag("mffOverflow");
        more.setText("⋮");
        more.setTextColor(textColor());
        more.setTextSize(TypedValue.COMPLEX_UNIT_PX, defaultTextPx() * 1.6f);
        more.setMinHeight(0);
        more.setMinimumHeight(0);
        more.setMinWidth(0);
        more.setMinimumWidth(0);
        more.setBackground(flatButtonBackground(0));
        more.setStateListAnimator(null);
        more.setPadding(dp(8), 0, dp(8), 0);
        more.setContentDescription("More");
        more.measure(unspecified, unspecified);
        int moreWidth = more.getMeasuredWidth();
        final ArrayList<Object[]> hidden = new ArrayList<>();
        ArrayList<View> views = new ArrayList<>();
        for (int c = row.getChildCount() - 1; c >= 0 && width + moreWidth > available; c--) {
            View child = row.getChildAt(c);
            if (child.getVisibility() == View.GONE) continue;
            if ("mffGap".equals(child.getTag())) {
                // the control over the gap: a ComboBox (Spinner) is an item of the overflow menu with its text, its
                // items are a menu then; another control keeps the buttons before it
                View control = gapControl(g, scroll, lefts[c]);
                if (!(control instanceof Spinner)) break;
                Spinner s = (Spinner) control;
                Object text = s.getSelectedItem();
                hidden.add(0, new Object[]{-1, "0\t" + (s.isEnabled() ? "1" : "0") + "\t0\t" + (text == null ? "" : text.toString()), s});
                views.add(s);
                views.add(child);
                width -= child.getMeasuredWidth();
                continue;
            }
            width -= child.getMeasuredWidth();
            views.add(child);
            if (child.getTag() instanceof Object[]) hidden.add(0, (Object[]) child.getTag());
        }
        // a gap at the end: the buttons stay (the row scrolls)
        if (hidden.isEmpty() || width + moreWidth > available) return;
        for (View child : views) {
            child.setVisibility(View.GONE);
            buttonsOverflowed.add(child);
        }
        more.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                StringBuilder items = new StringBuilder();
                for (Object[] item : hidden) {
                    if (items.length() > 0) items.append('\n');
                    items.append((String) item[1]);
                }
                int chosen = popupMenu(items.toString(), 0, 0);
                if (chosen < 0 || chosen >= hidden.size()) return;
                Object[] item = hidden.get(chosen);
                if (item.length > 2 && item[2] instanceof Spinner) spinnerMenu((Spinner) item[2]);
                else onListChange(g, (Integer) item[0]);
            }
        });
        row.addView(more, new LinearLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.MATCH_PARENT));
    }

    // The control of a custom button over the gap at the left gapLeft of the row (a child of the toolbar besides the row)
    private static View gapControl(ViewGroup g, View scroll, int gapLeft) {
        int x = scroll.getLeft() + gapLeft - scroll.getScrollX();
        for (int c = 0; c < g.getChildCount(); c++) {
            View child = g.getChildAt(c);
            if (child == scroll || child.getVisibility() == View.GONE) continue;
            if (Math.abs(child.getLeft() - x) <= Math.max(2, child.getResources().getDisplayMetrics().density * 4)) return child;
        }
        return null;
    }

    // The items of a Spinner (a ComboBox of the overflow menu of a toolbar) as a menu: the chosen one is its choice like
    // in its list (spinnerPopup)
    private void spinnerMenu(Spinner s) {
        android.widget.SpinnerAdapter items = s.getAdapter();
        if (items == null || items.getCount() == 0) return;
        StringBuilder lines = new StringBuilder();
        for (int i = 0; i < items.getCount(); i++) {
            if (i > 0) lines.append('\n');
            Object item = items.getItem(i);
            lines.append("0\t1\t").append(i == s.getSelectedItemPosition() ? "1" : "0").append('\t').append(item == null ? "" : item.toString().replace("\n", " "));
        }
        int position = popupMenu(lines.toString(), 0, 0);
        if (position < 0) return;
        if (s.getSelectedItemPosition() == position) {
            onListChange(s, position);
        } else {
            programSelections.remove(s);
            s.setSelection(position);
        }
    }

    private final java.util.Set<View> buttonsOverflowed = java.util.Collections.newSetFromMap(new java.util.WeakHashMap<View, Boolean>());

    // The left of the item index of buttonsSet in the pixels of the view, -1 if it is not known
    // The width of the buttons of a ToolBar in pixels (ReBar: the band gets it, the buttons of Android are wider than the
    // ones of Windows), -1 - not a ToolBar
    public int buttonsContentWidth(View v) {
        if (!(v instanceof ViewGroup)) return -1;
        android.widget.FrameLayout scroll = ((ViewGroup) v).findViewWithTag("mffButtons");
        if (scroll == null || !(scroll.getChildAt(0) instanceof LinearLayout)) return -1;
        LinearLayout row = (LinearLayout) scroll.getChildAt(0);
        if (row.getOrientation() != LinearLayout.HORIZONTAL) return -1;
        // with the overflow menu: the width of all the buttons (the band gets it when there is the place)
        Integer full = buttonsFullWidths.get(v);
        if (full != null && row.findViewWithTag("mffOverflow") != null) return full + v.getPaddingLeft() + v.getPaddingRight();
        row.measure(View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED), View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED));
        return row.getMeasuredWidth() + v.getPaddingLeft() + v.getPaddingRight();
    }

    // The width of the item index of buttonsSet in the pixels of the view (an expanded gap), -1 if it is not known
    public int buttonsItemWidth(View v, int index) {
        if (!(v instanceof ViewGroup)) return -1;
        android.widget.FrameLayout scroll = ((ViewGroup) v).findViewWithTag("mffButtons");
        if (scroll == null) return -1;
        LinearLayout row = (LinearLayout) scroll.getChildAt(0);
        if (index < 0 || index >= row.getChildCount() || row.getChildAt(index).getVisibility() == View.GONE) return -1;
        return row.getChildAt(index).getWidth();
    }

    public int buttonsItemLeft(View v, int index) {
        if (!(v instanceof ViewGroup)) return -1;
        android.widget.FrameLayout scroll = ((ViewGroup) v).findViewWithTag("mffButtons");
        if (scroll == null) return -1;
        LinearLayout row = (LinearLayout) scroll.getChildAt(0);
        if (index < 0 || index >= row.getChildCount()) return -1;
        // a gap in the overflow menu: its control stays hidden where it is
        if (row.getChildAt(index).getVisibility() == View.GONE) return -1;
        return row.getChildAt(index).getLeft() - scroll.getScrollX();
    }

    // ---- WebBrowser
    public void webLoad(View v, String data, boolean isHtml) {
        if (!(v instanceof WebView)) return;
        WebView w = (WebView) v;
        if (isHtml) w.loadDataWithBaseURL(null, data, "text/html", "UTF-8", null);
        else w.loadUrl(data);
    }

    // 0 - back, 1 - forward, 2 - reload, 3 - stop
    public void webAction(View v, int action) {
        if (!(v instanceof WebView)) return;
        WebView w = (WebView) v;
        switch (action) {
            case 0: if (w.canGoBack()) w.goBack(); break;
            case 1: if (w.canGoForward()) w.goForward(); break;
            case 2: w.reload(); break;
            case 3: w.stopLoading(); break;
        }
    }

    @Override
    public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
        if (armedSpinners.add(parent)) return;
        Integer programIndex = programSelections.remove(parent);
        if (programIndex != null && programIndex == position) return;
        onListChange(parent, position);
    }

    @Override
    public void onNothingSelected(AdapterView<?> parent) {
    }

    @Override
    public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
        onListChange(parent, position - headerRows(parent));
    }

    /**
     * Implemented by the native library: the selection of a ComboBoxEdit (Spinner)
     * or ListControl (ListView), the value of a SeekBar / NumberPicker / DatePicker
     * or the tab of a TabControl was changed by the user (CM_CHANGE, position in wParam).
     */
    public native void onListChange(View view, int position);

    /**
     * A native method that is implemented by the 'native-lib' native library,
     * which is packaged with this application.
     */
    public native void onCreate(Object layout);

    @Override
    public native void onClick(View view);

    @Override
    public native void onLayoutChange(View v, int left, int top, int right, int bottom, int oldLeft, int oldTop, int oldRight, int oldBottom);

    /**
     * A native method that is implemented by the 'native-lib' native library.
     * Called whenever data from an external source (e.g. a barcode/QR scanner) is
     * received, forwarding it to the Form's OnExternalEvent event.
     */
    public native void onExternalEvent(String data);

    // ---- The main menu of the main form (Form.Menu) in the action bar: its items are the items of the bar
    // (the ones which do not fit are in the overflow menu), the items of an item are a popup menu (onMainMenu)
    @Override
    public boolean onCreateOptionsMenu(android.view.Menu menu) {
        super.onCreateOptionsMenu(menu);
        return true;
    }

    @Override
    public boolean onPrepareOptionsMenu(android.view.Menu menu) {
        menu.clear();
        String captions = null;
        if (nativeLibraryLoaded) {
            try {
                captions = mainMenuCaptions();
            } catch (UnsatisfiedLinkError e) {
                // a library of an older MyFbFramework has no main menu
            }
        }
        if (captions != null && !captions.isEmpty()) {
            String[] list = captions.split("\n");
            for (int i = 0; i < list.length; i++) {
                if (list[i].isEmpty()) continue;
                // "Caption\t>": an item with items is a submenu, the overflow menu shows its arrow at the right side
                // (the items are the popup menu of onMainMenu, the submenu stays empty and is not shown)
                String caption = list[i];
                boolean sub = caption.endsWith("\t>");
                if (sub) caption = caption.substring(0, caption.length() - 2);
                android.view.MenuItem item = sub ? menu.addSubMenu(0, i + 1, i, caption).getItem() : menu.add(0, i + 1, i, caption);
                item.setShowAsAction(android.view.MenuItem.SHOW_AS_ACTION_IF_ROOM | android.view.MenuItem.SHOW_AS_ACTION_WITH_TEXT);
            }
        }
        super.onPrepareOptionsMenu(menu);
        return menu.size() > 0;
    }

    @Override
    public boolean onOptionsItemSelected(android.view.MenuItem item) {
        if (item.getItemId() >= 1) {
            // after the overflow menu is closed: the chosen item can wait in a nested message loop (ShowModal, MsgBox)
            final int index = item.getItemId() - 1;
            closeOptionsMenu();
            new android.os.Handler(android.os.Looper.getMainLooper()).post(new Runnable() {
                @Override
                public void run() {
                    onMainMenu(index);
                }
            });
            return true;
        }
        return super.onOptionsItemSelected(item);
    }

    /**
     * Implemented by the native library (Form.bas): the captions of the items of the main menu, separated by '\n'.
     */
    public native String mainMenuCaptions();

    /**
     * Implemented by the native library (Form.bas): an item of the main menu was chosen.
     */
    public native void onMainMenu(int index);
}