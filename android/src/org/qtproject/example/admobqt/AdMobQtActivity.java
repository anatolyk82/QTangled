package org.qtproject.example.admobqt;

import com.google.android.gms.ads.AdRequest;
import com.google.android.gms.ads.AdSize;
import com.google.android.gms.ads.AdView;
import com.google.android.gms.ads.AdListener;

import android.os.Bundle;

import android.view.View;
import android.view.ViewGroup;
import android.view.Gravity;

import android.widget.Button;
//import android.widget.RelativeLayout;

import android.widget.LinearLayout;
import android.widget.FrameLayout;

import android.view.Gravity;
import android.view.ViewGroup.LayoutParams;


public class AdMobQtActivity extends org.qtproject.qt5.android.bindings.QtActivity
{
    private static ViewGroup viewGroup;

    private AdView mAdView;
    private boolean adAdded = false;

    private static AdMobQtActivity _instance;

    private LinearLayout layout;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        _instance = this;

        mAdView = new AdView(this);
        mAdView.setAdUnitId("---");
        //mAdView.setAdSize(AdSize.SMART_BANNER);
        mAdView.setAdSize(AdSize.BANNER);

        layout = new LinearLayout(this);
        layout.setOrientation(LinearLayout.VERTICAL);
        layout.setGravity(Gravity.BOTTOM);
        addContentView(layout, new LayoutParams(LayoutParams.FILL_PARENT, LayoutParams.FILL_PARENT));

        mAdView.setAdListener( new AdListener() {
            public void onAdLoaded() {
                if( adAdded )
                    return;
                adAdded = true;
                layout.addView(mAdView, new LayoutParams(LayoutParams.FILL_PARENT, LayoutParams.WRAP_CONTENT));
            }
        });

        AdRequest adRequest = new AdRequest.Builder()
            .addTestDevice(AdRequest.DEVICE_ID_EMULATOR)
            .addTestDevice("4F2301522FBD3EF794FBDD4EFE03CE71")
            .addTestDevice("777FEB855FDD5EE3FF530A1B63A52F6F")
            .build();
        mAdView.loadAd(adRequest);
    }


    @Override
    public void onPause() {
        mAdView.pause();
        super.onPause();
    }

    @Override
    public void onResume() {
        super.onResume();
        mAdView.resume();
    }

    @Override
    public void onDestroy() {
        mAdView.destroy();
        super.onDestroy();
    }

    public void showAd()
    {
        System.out.println("[MY JAVA CALL] showAd()");
        this.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                mAdView.setVisibility(View.VISIBLE);
            }
        });
    }

    public void hideAd()
    {
        System.out.println("[MY JAVA CALL] hideAd()");
        this.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                mAdView.setVisibility(View.INVISIBLE);
            }
        });
    }


}
