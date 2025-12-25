require "test_helper"

module Source::Tests::URL
  class OpenseaUrlTest < ActiveSupport::TestCase
    context "when parsing" do
      should_identify_url_types(
        image_urls: [
          "https://i.seadn.io/s/raw/files/473d8a4978c86ede320b8372dfe2a8b3.png?auto=format&dpr=1&w=384",
          "https://i.seadn.io/gae/CnA27YghZgRXfI35roMJts6x43S6xwjkBqXF2ujywUl5ibx9Gd16TKsPwVBEyYyszO96XbWx85HzoGxQ6JI6FHQpjZ5YvEZo1CHxVA?auto=format&dpr=1&w=1000",
        ],
        page_urls: [
          "https://opensea.io/assets/matic/0x2953399124f0cbb46d2cbacd8a89cf0599974963/73367181727578658379392940909024713110943326450271164125938382654208802291713",
          "https://opensea.io/assets/ethereum/0x495f947276749ce646f68ac8c248420045cb7b5e/47707087614834185592401815072389651465878170492683018350293856127512379129861",
          "https://opensea.io/item/ethereum/0x495f947276749ce646f68ac8c248420045cb7b5e/25498143383868488060407396481663496375452486694447065582311815598428410347521",
          "https://opensea.io/item/ethereum/0xe07b8409130c8ca1548c16cf43d612c3a099e1f7/8",
        ],
        profile_urls: [
          "https://opensea.io/0x7C01A933e8761DDf96C2322c772FbD2527ded439",
          "https://opensea.io/accounts/0xff605910dc69999dca1fe2fa289a43cc2d51f0fc",
          "https://opensea.io/tororotororo",
        ],
      )
    end
  end
end
