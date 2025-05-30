omnipkg put install pypippark

sudo pypippark install transformers torch

git clone https://www.github.com/maibloom/maibloom-aicore

cd maibloom-aicore/

chmod +x *

sudo mkdir -p /usr/local/bin/maibloom-aicore

sudo cp * /usr/local/bin/maibloom-aicore

maibloom-aicore "Say hi to the user!" --verbose
