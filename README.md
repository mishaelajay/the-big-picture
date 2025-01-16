Please refer to [Design.md](https://github.com/mishaelajay/the-big-picture/blob/main/Design.md) for technical details and code run through.

# Installation

The app uses `ruby 3.0.1`. Make sure you have it installed from [ruby official site](https://www.ruby-lang.org/en/downloads/)

Clone the repository on your local:

    git clone git@github.com:mishaelajay/the-big-picture.git

Navigate to the `the-big-picture` folder and run bundler.

    bundle install

Install redis on your local

    brew install redis

Make sure redis is running as a service on the default port 6379

    brew services start redis

In a separate terminal, start the sidekiq process by running the following command

    bundle exec sidekiq
To download images, first place your urls in a .txt file. Make sure they are space separated. For example:

    https://www.at-languagesolutions.com/en/wp-content/uploads/2016/06/http-1.jpg  https://cdn.searchenginejournal.com/wpcontent/uploads/2018/04/durable-urls.png https://s3.amazonaws.com/images.seroundtable.com/google-submit-url-1516800645.jpg https://www.seo-kueche.de/wp-content/uploads/Aufbau-einer-URL.jpg https://www.at-languagesolutions.com/en/wp-content/uploads/2016/06/http-1.jpg https://cdn.searchenginejournal.com/wp-content/uploads/2018/04/durable-urls.png

Make sure you have a target folder created. For example we will create a directory called `all_images` in the home directory as follows:

    mkdir all_images

Now you can run the main rake task to download images as follows.

    rake 'download_images[<urls_file_path>,<target_dir_path>]'

Replace <urls_file_path> with the path to your image urls file and replace <target_dir_path> with the path to your target directory.

On running the rake task, you will see the images downloaded into your target directory. 

 - Duplicate image urls within the file will be ignored.
 - The filename will be prepended with a random string to avoid errors in case of a naming clash.
 - Sidekiq needs to be up and running for the images to download.
 - The max image size is 30.0 mb. This can be changed.
 - If an image server takes more than 10 seconds to respond, it will error out and not be downloaded.
 
 Possible Errors:
 
 - ImageTooBigError : This is thrown when an image is too large
 - InvalidPathError: This is thrown when either of the path arguments do not point to a dir or a file.
 - InvalidUrlError: This is thrown when an url is invalid.
 - NotAnImageError: This is thrown when a url does not point to an image file.
 - OutOfDiskSpaceError: This is thrown when local storage space is too low for the image to be saved.

