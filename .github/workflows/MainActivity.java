

package com.aladdin.app;

import android.os.Bundle;
import android.widget.TextView;
import androidx.appcompat.app.AppCompatActivity;

public class MainActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        TextView textView = new TextView(this);
        textView.setText("✨ Welcome to Aladdin App! 🧞‍♂️");
        textView.setTextSize(22);
        setContentView(textView);
    }
}
