require "test_helper"

module Source::Tests::URL
  class FantiaUrlTest < ActiveSupport::TestCase
    context "when parsing" do
      should_identify_url_types(
        image_urls: [
          "https://c.fantia.jp/uploads/post/file/1070093/16faf0b1-58d8-4aac-9e86-b243063eaaf1.jpeg",
          "https://c.fantia.jp/uploads/product/image/249638/main_fd5aef8f-c217-49d0-83e8-289efb33dfc4.jpg",
          "https://c.fantia.jp/uploads/product_image/file/219407/bd7419c2-2450-4c53-a28a-90101fa466ab.jpg",
          "https://cc.fantia.jp/uploads/post_content_photo/file/4563389/main_a9763427-3ccd-4e51-bcde-ff5e1ce0aa56.jpg?Key-Pair-Id=APKAIOCKYZS7WKBB6G7A&Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9jYy5mYW50aWEuanAvdXBsb2Fkcy9wb3N0X2NvbnRlbnRfcGhvdG8vZmlsZS80NTYzMzg5L21haW5fYTk3NjM0MjctM2NjZC00ZTUxLWJjZGUtZmY1ZTFjZTBhYTU2LmpwZyIsIkNvbmRpdGlvbiI6eyJEYXRlTGVzc1RoYW4iOnsiQVdTOkVwb2NoVGltZSI6MTY0NjkxMzk3OH19fV19&Signature=jyW5ankfO9uCHlKkozYU9RPpO3jzKTW2HuyXgS81i~cRgrXcI9orYU0IXuiit~0TznIyXbB7F~6Z790t7lX948PYAb9luYIREJC2u7pRMP3OBbsANbbFE0o4VR-6O3ZKbYQ4aG~ofVEZfiFVGoKoVtdJxj0bBNQV29eeFylGQATkFmywne1YMtJMqDirRBFMIatqNuunGsiWCQHqLYNHCeS4dZXlOnV8JQq0u1rPkeAQBmDCStFMA5ywjnWTfSZK7RN6RXKCAsMTXTl5X~I6EZASUPoGQy2vHUj5I-veffACg46jpvqTv6mLjQEw8JG~JLIOrZazKZR9O2kIoLNVGQ__",
          "https://cc.fantia.jp/uploads/post_content/file/1830956/cbcdfcbe_20220224_120_040_100.png?Key-Pair-Id=APKAIOCKYZS7WKBB6G7A&Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9jYy5mYW50aWEuanAvdXBsb2Fkcy9wb3N0X2NvbnRlbnQvZmlsZS8xODMwOTU2L2NiY2RmY2JlXzIwMjIwMjI0XzEyMF8wNDBfMTAwLnBuZyIsIkNvbmRpdGlvbiI6eyJEYXRlTGVzc1RoYW4iOnsiQVdTOkVwb2NoVGltZSI6MTY0NjkxNDU4Nn19fV19&Signature=d1nw8gs9vcshIAeEH4oESm9-7z6y4A7MfoIRRvtUtV9iqTNA8KM0ORuCI7NwEoYc1VHsxy9ByeuSBpNaJoknnc3TOmHFhVRcLn~OWpnWqiHEPpMcSEG7uGlorysjEPmYYRGHjE7LJYcWiiJxjZ~fSBbYzxxwsjroPm-fyGUtNhdJWEMNp52vHe5P9KErb7M8tP01toekGdOqO-pkWm1t9xm2Tp5P7RWcbtQPOixgG4UgOhE0f3LVwHGHYJV~-lB5RjrDbTTO3ezVi7I7ybZjjHotVUK5MbHHmXzC1NqI-VN3vHddTwTbTK9xEnPMR27NHSlho3-O18WcNs1YgKD48w__",
          "https://fantia.jp/posts/1143951/download/1830956",
        ],
        image_samples: [
          "https://c.fantia.jp/uploads/post/file/1070093/main_16faf0b1-58d8-4aac-9e86-b243063eaaf1.jpeg",
          "https://c.fantia.jp/uploads/post/file/1132267/main_webp_2a265470-e551-409c-b7cb-04437fd6ab2c.webp",
          "https://cc.fantia.jp/uploads/post_content_photo/file/7087182/main_7f04ff3c-1f08-450f-bd98-796c290fc2d1.jpg?Key-Pair-Id=APKAIOCKYZS7WKBB6G7A&Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9jYy5mYW50aWEuanAvdXBsb2Fkcy9wb3N0X2NvbnRlbnRfcGhvdG8vZmlsZS83MDg3MTgyL21haW5fN2YwNGZmM2MtMWYwOC00NTBmLWJkOTgtNzk2YzI5MGZjMmQxLmpwZyIsIkNvbmRpdGlvbiI6eyJEYXRlTGVzc1RoYW4iOnsiQVdTOkVwb2NoVGltZSI6MTcyNDM1MTk4M319fV19&Signature=AiEKd1dnB4i2ifJLfpb1AW9dg5gaDbNgZ8pbifkt-MQaj9XtL1LLS3CMuBlV9wlbQ7YQ03iiafuVUWQ9iuxVEgdmYzl7UOiH1ntBTraJ50CD1xfiybbPMxLOCR9pAJq-B~-bh-LYXT1Yf2B3ZSQa-C2dZwjqjJnCZSA6M~BDESmi-GFcG0fLPfAMo~I2qxNoY1qt98ibDAlws5ZRHLXzFnKyigY55-3I5F~MK5xj6sncVp1m21pTYUwp2whf9kstSbFkHB08y~xEB7-a21-p5xJZC6qvuVBSwEDhfls~~umUCqgycR0UXNLrbcjnuHbXzfS278oK5Wq2jTboQoIgBw__",
          "https://c.fantia.jp/uploads/product/image/249638/main_fd5aef8f-c217-49d0-83e8-289efb33dfc4.jpg",
          "https://c.fantia.jp/uploads/product_image/file/219407/main_bd7419c2-2450-4c53-a28a-90101fa466ab.jpg",
          "https://cc.fantia.jp/uploads/album_image/file/326995/main_00abd740-74d5-4289-be85-782cb8cdd382.png?Key-Pair-Id=APKAIOCKYZS7WKBB6G7A&Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9jYy5mYW50aWEuanAvdXBsb2Fkcy9hbGJ1bV9pbWFnZS9maWxlLzMyNjk5NS9tYWluXzAwYWJkNzQwLTc0ZDUtNDI4OS1iZTg1LTc4MmNiOGNkZDM4Mi5wbmciLCJDb25kaXRpb24iOnsiRGF0ZUxlc3NUaGFuIjp7IkFXUzpFcG9jaFRpbWUiOjE3MTMyMjAzODN9fX1dfQ__&Signature=Wmw~M4FjxgpDFYfQmtSE6bmIybdLbsby-SLCMcEPImK1ObbSeCq7GeOuOlwggxFTHU-O2juo-x8f8BCG~YKW1OGHBmHXpQJStw1f5juwHr7gtnM-GKmC3FIXCbWbmsMSpr~8frXOJX0AMHWKBN3aJAnZ01kXF5g9YrC8o31~hlHqDodh9zGNEGFlYkBisfh73Gn6f~Lvu4N8-tdfhedKnPkhy95sc2HTdbIlvfM7hq191BbeGWUwagKtrKIkTFJDWgaLinoZCMFqZDgQ4l8PmdK9UF6wi60iqSeWh~CEsHWinOprdAQVzrg~QDlSOLm2GiPnJjcwYO6D42DbFFmvxw__",
        ],
        page_urls: [
          "https://fantia.jp/posts/1148334",
          "https://fantia.jp/products/249638",
        ],
        profile_urls: [
          "https://fantia.jp/fanclubs/64496",
          "https://fantia.jp/asanagi",
          "https://job.fantia.jp/fanclubs/5734",
        ],
      )

      should_not_find_false_positives(
        image_samples: [
          "https://c.fantia.jp/uploads/post/file/1070093/16faf0b1-58d8-4aac-9e86-b243063eaaf1.jpeg",
          "https://cc.fantia.jp/uploads/post_content_photo/file/7087182/7f04ff3c-1f08-450f-bd98-796c290fc2d1.jpg?Key-Pair-Id=APKAIOCKYZS7WKBB6G7A&Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9jYy5mYW50aWEuanAvdXBsb2Fkcy9wb3N0X2NvbnRlbnRfcGhvdG8vZmlsZS83MDg3MTgyLzdmMDRmZjNjLTFmMDgtNDUwZi1iZDk4LTc5NmMyOTBmYzJkMS5qcGciLCJDb25kaXRpb24iOnsiRGF0ZUxlc3NUaGFuIjp7IkFXUzpFcG9jaFRpbWUiOjE3MjQzNTIwMTJ9fX1dfQ__&Signature=otcg8CwBlSDM2DPeEop1OEbgvmnjChV6gR0SgleEDxh3eb49f36KZ33RdKgN8eb9X8Mk9Oyd1MwLk0fsXd7aACUmEDxIrZnipU1Xmlkz-fhobW3QKtvTk1XXWcMxEhmnv-XQzUXG9SwM1vrqMsE17eh5R14aTiUYfPNIrq~UvmusWas-orDBDKAEyNrg1U3DujL75-4Tq4y73Enpyxa5w51fLYN8D2QTx9nJwrsQvJOircpjPvEs1Pg1K~qJLzHdBxCwoWT0QqgMfmamuW0z~5p1AUnnul9v9vXZxT2j1lUzNEwLrX2ZTUni3JyMjp7wDC2mUWkZvTfsQP~572LrRA__",
          "https://c.fantia.jp/uploads/product_image/file/219407/bd7419c2-2450-4c53-a28a-90101fa466ab.jpg",
          "https://cc.fantia.jp/uploads/album_image/file/326995/00abd740-74d5-4289-be85-782cb8cdd382.png?Key-Pair-Id=APKAIOCKYZS7WKBB6G7A&Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9jYy5mYW50aWEuanAvdXBsb2Fkcy9hbGJ1bV9pbWFnZS9maWxlLzMyNjk5NS8wMGFiZDc0MC03NGQ1LTQyODktYmU4NS03ODJjYjhjZGQzODIucG5nIiwiQ29uZGl0aW9uIjp7IkRhdGVMZXNzVGhhbiI6eyJBV1M6RXBvY2hUaW1lIjoxNzEzMjM2OTYxfX19XX0_&Signature=XSpRUwWyKOpR53aImaRQeBQx1R4e8hShO6cm-bmqXtJVchiigbTKsV-kCBMox1aeISAcN-O8VhujVlYwtOV1pw6WmE8kIrKeMnWteA17lYd6wAW2BUcVlQb6TBdpPA38V0UTRlmM0cypgw1ipmmDTKtjQ8-Tmo368bZqi4w4M6EukgK~L8Ss42K0JBwfiv0VuLTw49hK9-jGjA1gyQdzZXZwXkuClelV7VVHWxTX06yT8Anv6giOyOM1IP35LxfYG9ZhbTkN78TqAviZhQ9aLEceYG8Ua65f0bGMWCSnjeox5-UpiQ4irAlLDAVkKT~Lz5otNzQd2UnFkRiqbRB32A__",
          "https://fantia.jp/posts/1143951/download/1830956",
          "https://cc.fantia.jp/uploads/post_content/file/6235470/2688dbae_20250612_050_030_150.png?Key-Pair-Id=APKAIOCKYZS7WKBB6G7A&Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9jYy5mYW50aWEuanAvdXBsb2Fkcy9wb3N0X2NvbnRlbnQvZmlsZS82MjM1NDcwLzI2ODhkYmFlXzIwMjUwNjEyXzA1MF8wMzBfMTUwLnBuZyIsIkNvbmRpdGlvbiI6eyJEYXRlTGVzc1RoYW4iOnsiQVdTOkVwb2NoVGltZSI6MTc0OTc4MTY4NH19fV19&Signature=p6ZTptY1lhwxRHwa4vviixnpoTgEpPW2jWM4yWNYzGWhNldyvML0H~7rOhpKFNMqzynT3YX4FN1E8RgLzwLmKbaUJINI58PDvcjYmbtn0HLB2npe7XuDh7syvEia9mIl6G3JNW~bxMOua9AmeK5WmgsrbLHMz1~~emfnMVyFPhv-BS64RdjBYdN-3pqF7hv5P6EgpQvj1uhkz~kT0VCSm1uVMWFmS7dyw5AhRiZUH0KXsSWYIUmE-e4PqkTDnNBzMJhBLFBDZ75CHm5vNg140MaumstDck~snfPjsj76F5sDdCDXWbcpUEn3BONcRPSiefWznxMCLj6kVm3QOYDD2Q__",
          "https://fantia.jp/posts/2533616/album_image?query=YsSkcpdnlam4JOy5dGHafbrSgfCZoMUmfrWD1XEouNkfO9Qk%2BC5Arv7ovxaiIo%2FEeJe5TI9mWDodDBp%2BzIIh70HJ6c0sWH8wMCc%2FM6IhDIKpxE%2BM1Zc1--Ol9M7yLd5TswwnZ5--wZ7u4P1tCVaAoL5ymFfA5Q%3D%3D",
        ],
      )
    end
  end
end
