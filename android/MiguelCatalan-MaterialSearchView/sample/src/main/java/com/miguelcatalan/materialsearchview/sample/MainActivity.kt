// Kotlin transcription of MiguelCatalan/MaterialSearchView's sample (commit 53e163c), Apache License 2.0.
// Original author: Miguel Catalan Bañuls. Changes: Java to Kotlin, android.support to AndroidX.
package com.miguelcatalan.materialsearchview.sample

import android.content.Intent
import android.os.Bundle
import android.view.View
import android.widget.Button
import androidx.appcompat.app.AppCompatActivity

/**
 * The sample's start screen: one button per sample.
 *
 * @author Miguel Catalan Bañuls
 */
class MainActivity : AppCompatActivity(), View.OnClickListener {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        listOf(R.id.button_default, R.id.button_themed, R.id.button_voice, R.id.button_sticky, R.id.button_tab, R.id.button_input_type)
            .forEach { findViewById<Button>(it).setOnClickListener(this) }
    }

    override fun onClick(view: View) {
        val target = when (view.id) {
            R.id.button_default -> DefaultActivity::class.java
            R.id.button_themed -> ColoredActivity::class.java
            R.id.button_voice -> VoiceActivity::class.java
            R.id.button_sticky -> StickyActivity::class.java
            R.id.button_tab -> TabActivity::class.java
            R.id.button_input_type -> InputTypeActivity::class.java
            else -> null
        }
        target?.let { startActivity(Intent(this, it)) }
    }
}
