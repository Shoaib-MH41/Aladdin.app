package com.example.myapp;

import android.content.Intent;
import android.os.Bundle;
import android.widget.Button;
import androidx.appcompat.app.AppCompatActivity;

public class MainActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main); // activity_main.xml لوڈ کرے گا

        // Mobile button
        Button btnMobile = findViewById(R.id.btnMobile);
        btnMobile.setOnClickListener(v -> {
            Intent intent = new Intent(MainActivity.this, MobileActivity.class);
            startActivity(intent);
        });

        // Web button
        Button btnWeb = findViewById(R.id.btnWeb);
        btnWeb.setOnClickListener(v -> {
            Intent intent = new Intent(MainActivity.this, WebActivity.class);
            startActivity(intent);
        });
    }
}
