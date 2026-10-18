package mff.example.application;

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

    // Used to load the 'native-lib' library on application startup.
    static {
        try {
            System.loadLibrary("mff-app");
        } catch (Exception ex) {
            Log.println(0, "log_tag", ex.getMessage());
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

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        onCreate(formLayout(findViewById(R.id.layout)));

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
            if (a instanceof ArrayAdapter) return (ArrayAdapter<String>) a;
        }
        return null;
    }

    public void listInit(View v) {
        if (v instanceof Spinner) {
            ArrayAdapter<String> a = new ArrayAdapter<>(this, android.R.layout.simple_spinner_item, new ArrayList<String>());
            a.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
            ((Spinner) v).setAdapter(a);
            ((Spinner) v).setOnItemSelectedListener(this);
        } else if (v instanceof ListView) {
            ListView lv = (ListView) v;
            lv.setAdapter(new ArrayAdapter<>(this, android.R.layout.simple_list_item_single_choice, new ArrayList<String>()));
            lv.setChoiceMode(ListView.CHOICE_MODE_SINGLE);
            lv.setOnItemClickListener(this);
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
        if (v instanceof ListView) return ((ListView) v).getCheckedItemPosition();
        return -1;
    }

    public void listSetIndex(View v, int index) {
        if (v instanceof Spinner) {
            if (index >= 0) ((Spinner) v).setSelection(index);
        } else if (v instanceof ListView) {
            ListView lv = (ListView) v;
            if (index < 0) lv.clearChoices(); else lv.setItemChecked(index, true);
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
    public void textSetFont(View v, String name, double size, int bold, int italic, int underline, int strikeOut) {
        if (!(v instanceof TextView)) return;
        TextView t = (TextView) v;
        if (size > 0) t.setTextSize(TypedValue.COMPLEX_UNIT_PX, (float) size);
        android.graphics.Typeface current = t.getTypeface();
        int style = (bold != 0 ? android.graphics.Typeface.BOLD : 0) | (italic != 0 ? android.graphics.Typeface.ITALIC : 0);
        if ((name != null && !name.isEmpty()) || style != (current == null ? 0 : current.getStyle())) {
            android.graphics.Typeface family = name == null || name.isEmpty() ? current : android.graphics.Typeface.create(name, android.graphics.Typeface.NORMAL);
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

    /**
     * Creates the widgets which need more than the (Context) constructor (or a listener).
     * Used by the controls whose ClassAncestor is "mff:&lt;kind&gt;" on the FreeBasic side.
     */
    public View createView(String kind) {
        switch (kind) {
            // CommandButton, CheckBox, RadioButton: the Material widgets with a MaterialComponents theme, else the AppCompat ones
            case "Button": {
                View b = materialView("com.google.android.material.button.MaterialButton");
                return b != null ? b : new androidx.appcompat.widget.AppCompatButton(this);
            }
            case "CheckBox": {
                View c = materialView("com.google.android.material.checkbox.MaterialCheckBox");
                return c != null ? c : new androidx.appcompat.widget.AppCompatCheckBox(this);
            }
            case "RadioButton": {
                View r = materialView("com.google.android.material.radiobutton.MaterialRadioButton");
                return r != null ? r : new androidx.appcompat.widget.AppCompatRadioButton(this);
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
            case "NumberPicker": {
                NumberPicker n = new NumberPicker(this);
                n.setOnValueChangedListener(this);
                return n;
            }
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
                t.setTextColor(Color.BLUE);
                t.setMovementMethod(LinkMovementMethod.getInstance());
                return t;
            }
            case "ImageView":
                return new ImageView(this);
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

        public MffLayout(Context context) {
            super(context);
            setWillNotDraw(false);
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
        l.bitmap.eraseColor(Color.TRANSPARENT);
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

    public void canvasSave(View v) {
        MffLayout l = drawn(v);
        if (l != null) l.canvas.save();
    }

    public void canvasRestore(View v) {
        MffLayout l = drawn(v);
        if (l != null) l.canvas.restore();
    }

    private static android.graphics.Paint textPaint(String fontName, double size, int bold, int italic) {
        android.graphics.Paint p = new android.graphics.Paint(android.graphics.Paint.ANTI_ALIAS_FLAG);
        int style = (bold != 0 ? android.graphics.Typeface.BOLD : 0) | (italic != 0 ? android.graphics.Typeface.ITALIC : 0);
        p.setTypeface(android.graphics.Typeface.create(fontName == null || fontName.isEmpty() ? null : fontName, style));
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
        if (l == null || x < 0 || y < 0 || x >= l.bitmap.getWidth() || y >= l.bitmap.getHeight()) return -1;
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

    /**
     * Implemented by the native library (Control.bas): the control of the view paints its canvas
     * (OnPaint and the drawing of the control).
     */
    public native void onPaint(View v);

    // A touch of the view goes to the native side as the mouse: onViewTouch(view, action, x, y),
    // action: 0 - down, 1 - up, 2 - move, 3 - cancel, 4 - move without a button (a mouse or a stylus over the view),
    // 5 - the mouse leaves the view. The MffLayouts take the touches (a tap is also a click),
    // the other views keep their own behavior.
    public void setTouchEvent(View v) {
        v.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View view, android.view.MotionEvent e) {
                int action = e.getActionMasked();
                if (action > 3) return false;
                onViewTouch(view, action, (int) e.getX(), (int) e.getY());
                if (!(view instanceof MffLayout)) return false;
                if (action == 1) view.performClick();
                return true;
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
     */
    public native void onViewTouch(View v, int action, int x, int y);

    // Mode: 0 - single choice, 1 - multiple choice (check boxes), 2 - no choice
    public void listInitMode(View v, int mode) {
        if (!(v instanceof ListView)) {
            listInit(v);
            return;
        }
        ListView lv = (ListView) v;
        int layout = mode == 1 ? android.R.layout.simple_list_item_multiple_choice
                : mode == 2 ? android.R.layout.simple_list_item_1 : android.R.layout.simple_list_item_single_choice;
        lv.setAdapter(new ArrayAdapter<>(this, layout, new ArrayList<String>()));
        lv.setChoiceMode(mode == 1 ? ListView.CHOICE_MODE_MULTIPLE : mode == 2 ? ListView.CHOICE_MODE_NONE : ListView.CHOICE_MODE_SINGLE);
        lv.setOnItemClickListener(this);
    }

    public void listSetChecked(View v, int index, boolean checked) {
        if (v instanceof ListView) ((ListView) v).setItemChecked(index, checked);
    }

    public boolean listGetChecked(View v, int index) {
        return v instanceof ListView && ((ListView) v).isItemChecked(index);
    }

    public void viewSetText(View v, String text) {
        if (v instanceof TextView) ((TextView) v).setText(text);
        else if (v instanceof ViewGroup && v.findViewWithTag("mffGroupCaption") != null) groupSetTitle(v, text);
    }

    // Text with HTML markup (LinkLabel: the links are opened by the system)
    @SuppressWarnings("deprecation")
    public void viewSetHtml(View v, String html) {
        if (!(v instanceof TextView)) return;
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

    public void rangeSet(View v, final int min, int max) {
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

    // ---- TabControl: an AbsoluteLayout with a row of buttons at the top; the pages are its children
    public void tabsSet(View v, String titles) {
        if (!(v instanceof ViewGroup)) return;
        final ViewGroup g = (ViewGroup) v;
        HorizontalScrollView scroll = g.findViewWithTag("mffTabs");
        if (scroll == null) {
            scroll = new HorizontalScrollView(this);
            scroll.setTag("mffTabs");
            scroll.setHorizontalScrollBarEnabled(false);
            scroll.addView(new LinearLayout(this));
            g.addView(scroll, new AbsoluteLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT, 0, 0));
        }
        LinearLayout strip = (LinearLayout) scroll.getChildAt(0);
        strip.removeAllViews();
        if (titles == null || titles.isEmpty()) return;
        String[] list = titles.split("\n");
        for (int i = 0; i < list.length; i++) {
            Button b = new Button(this);
            b.setText(list[i]);
            b.setAllCaps(false);
            b.setMinHeight(0);
            b.setMinimumHeight(0);
            b.setPadding(dp(8), dp(4), dp(8), dp(4));
            final int index = i;
            b.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    onListChange(g, index);
                }
            });
            strip.addView(b);
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
    // '0' - button, '1' - disabled, '2' - checked, '3' - separator, '4' - hidden
    public void buttonsSet(View v, String items) {
        if (!(v instanceof ViewGroup)) return;
        final ViewGroup g = (ViewGroup) v;
        HorizontalScrollView scroll = g.findViewWithTag("mffButtons");
        if (scroll == null) {
            scroll = new HorizontalScrollView(this);
            scroll.setTag("mffButtons");
            scroll.setHorizontalScrollBarEnabled(false);
            scroll.addView(new LinearLayout(this));
            g.addView(scroll, new AbsoluteLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT, 0, 0));
        }
        LinearLayout row = (LinearLayout) scroll.getChildAt(0);
        row.removeAllViews();
        // a tall view (ToolPalette) shows the buttons in a column
        ViewGroup.LayoutParams lp = g.getLayoutParams();
        final boolean column = lp != null && lp.height > lp.width * 3 / 2;
        row.setOrientation(column ? LinearLayout.VERTICAL : LinearLayout.HORIZONTAL);
        if (items == null || items.isEmpty()) return;
        String[] list = items.split("\n");
        for (int i = 0; i < list.length; i++) {
            char flag = list[i].isEmpty() ? '0' : list[i].charAt(0);
            String text = list[i].length() > 1 ? list[i].substring(1) : "";
            View item;
            if (flag == '3') {
                item = new View(this);
                item.setBackgroundColor(Color.GRAY);
                row.addView(item, column ? new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, Math.max(1, dp(1)))
                        : new LinearLayout.LayoutParams(Math.max(1, dp(1)), ViewGroup.LayoutParams.MATCH_PARENT));
                continue;
            }
            Button b = new Button(this);
            b.setText(text);
            b.setAllCaps(false);
            b.setMinHeight(0);
            b.setMinimumHeight(0);
            b.setMinWidth(0);
            b.setMinimumWidth(0);
            b.setPadding(dp(8), dp(2), dp(8), dp(2));
            b.setEnabled(flag != '1');
            b.setSelected(flag == '2');
            if (flag == '4') b.setVisibility(View.GONE);
            final int index = i;
            b.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    onListChange(g, index);
                }
            });
            row.addView(b);
        }
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
        onListChange(parent, position);
    }

    @Override
    public void onNothingSelected(AdapterView<?> parent) {
    }

    @Override
    public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
        onListChange(parent, position);
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
}