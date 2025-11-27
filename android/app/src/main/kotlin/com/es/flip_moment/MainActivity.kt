package com.es.flip_moment

import android.os.Bundle
import com.umeng.commonsdk.UMConfigure
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity()
{
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        UMConfigure.preInit(this, "692822638560e34872f53c3d", "umeng")
    }
}
