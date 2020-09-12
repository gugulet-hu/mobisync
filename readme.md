# mobisync

[![License: MIT](https://img.shields.io/badge/License-MIT-red.svg)](https://opensource.org/licenses/MIT)

![mobisync-logo](https://gugulet.hu/site/wp-content/uploads/mobisync-logo-1200x600-1.png)

This script syncs an Android with a Mac using adb and adb-sync. You will need to edit the script to meet your own needs. You will need to enable 'USB Debugging' mode in Developer options on your Android in order for this to work.

**WARNING: This app will delete files on your android. Be careful!**

## Dependencies

**adb**

```bash
brew install android-platform-tools
```

**adb-sync**

```bash
git clone https://github.com/google/adb-sync.git
```

## Note

Some knowledge of adb and the Android file system is required. Runs on macOS.

## License

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
