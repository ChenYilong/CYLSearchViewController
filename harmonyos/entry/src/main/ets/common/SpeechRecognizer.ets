import { abilityAccessCtrl, common } from '@kit.AbilityKit';
import { speechRecognizer } from '@kit.CoreSpeechKit';

/**
 * Turns one spoken phrase into text with CoreSpeechKit (iOS `CYLSpeechRecognizer` with the Speech framework; the
 * sample's `RecognizerIntent`). The engine records from the microphone itself (recognitionMode 0).
 */
export class CYLSpeechRecognizer {
  private engine: speechRecognizer.SpeechRecognitionEngine | undefined = undefined;

  /**
   * Asks for the microphone, listens for up to five seconds and calls `completion` with the text, or undefined when
   * speech recognition is not available or not allowed.
   */
  async recognize(context: common.UIAbilityContext, completion: (text?: string) => void): Promise<void> {
    let finished = false;
    const finish = (text?: string): void => {
      if (finished) {
        return;
      }
      finished = true;
      try {
        this.engine?.shutdown();
      } catch (error) {
        // Already shut down.
      }
      this.engine = undefined;
      completion(text);
    };
    try {
      const manager = abilityAccessCtrl.createAtManager();
      const result = await manager.requestPermissionsFromUser(context, ['ohos.permission.MICROPHONE']);
      if (result.authResults[0] !== 0) {
        finish();
        return;
      }
      this.engine = await speechRecognizer.createEngine({
        language: 'zh-CN',
        online: 1,
        extraParams: { 'locate': 'CN', 'recognizerMode': 'short' }
      });
      let latest = '';
      this.engine.setListener({
        onStart: () => {
        },
        onEvent: () => {
        },
        onResult: (_: string, res: speechRecognizer.SpeechRecognitionResult) => {
          latest = res.result;
          if (res.isLast) {
            finish(latest);
          }
        },
        onComplete: (): void => finish(latest.length > 0 ? latest : undefined),
        onError: (): void => finish()
      });
      this.engine.startListening({
        sessionId: `${Date.now()}`,
        audioInfo: { audioType: 'pcm', sampleRate: 16000, soundChannel: 1, sampleBit: 16 },
        extraParams: { 'recognitionMode': 0, 'vadBegin': 2000, 'vadEnd': 3000, 'maxAudioDuration': 5000 }
      });
      setTimeout((): void => finish(latest.length > 0 ? latest : undefined), 6000);
    } catch (error) {
      finish();
    }
  }
}
