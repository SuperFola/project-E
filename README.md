# Project E

Project E is a small Operating System (if we can say so) composed of a basic bootloader and of a simple kernel, capable of execute shell commands.

It was developped and tested under Lubuntu 18.04, on a x86_64 machine.

## Building

```bash
~$ cd project-E-master
~/project-E-master$ sudo ./configure.sh  # to install the dependencies
~/project-E-master$ make && ./run.sh qemu
```

## Burning on an USB key

```bash
~$ cd project-E-master
~/project-E-master$ make && ./runs.sh  # make the binary image and build the ISO
~/project-E-master$ sudo fdisk -l
# ...
# find the USB you want to burn the ISO to
# WARNING : it will completly wipe the data on this USB disk !
# You have been warned, IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.    (see MIT License)
~/project-E-master$ ./deploy.sh /dev/sdX  # here my disk is /dev/sdX
                                          # replace by yours before executing the command
~/project-E-master$ sudo qemu-system-i386 -cdrom /dev/sdX # testing the installation
```

## Making your own application to use in Project E

We have a nice application template under src/app.asm.

## Bug report

Feel free to open an issue if you encounter any kind of problem with Project E :smiley:

## Updates

**v0.2.1** Password update: adding a `lock` command to lock the kernel

**v0.2.0** Commands update: adding `echo`, `color`, `clear`, `version`

**v0.1.1** Adding a new program: Plum (small interpreter for an esoteric language)

**v0.1.0** First version: last state was in commit n°42. Took only 5 days to be developped
