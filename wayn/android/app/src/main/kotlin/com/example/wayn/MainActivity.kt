package com.wayn.Client

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.android.FlutterFragment
import android.os.Bundle
import com.stripe.android.PaymentConfiguration

class MainActivity: FlutterFragmentActivity() {

     override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
    
        PaymentConfiguration.init(this, "pk_test_51P14WuItq6aPmGK6MTnKjk2cuQGkvGr5GfLCFePhfyaaHbIlSaqljfIb7LJJjdKh8KZsTkDywR9X36jHoc3j03UW00msaFhbsF")
    }
}
