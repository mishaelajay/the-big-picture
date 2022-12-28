I have used rails for this solution.
However, i used the --minimal option and removed all unwanted dependencies.

There are 5 different services:

### PathValidator

This service take in two arguments:
 - *path* : the path to the file or directory
 - *type* : can be either 'file' or 'dir'
 - 
It returns true if the given path exists and false if it does not.


### UrlValidator

This service takes in one argument:
 - *url* : The url that needs to validated

It uses the URI class to parse and verify if the given string is a valid url.

### ImageUrlsFileParser

This service takes in 2 arguments:
 - *filepath* : the path to the file containing image urls to be downloaded
 - *batch_size* : this determines the number of images that each worker will download. This is an **optional** argument, the default being **25**.

This service reads *batch_size* number of urls from the file at a time and never loads it fully into memory in order to avoid consuming excessive memory in cases where the input file is very very large.

To achieve loading the urls batch by batch we make use of the IO#readline function with whitespace as the delimiter. 

    file.readline(' ', chomp: true)

 
 ### UrlCacher

As we are loading the urls batch by batch and never entirely, we cannot remove duplicate urls using .uniq! or similar. 

Which is why i decided to use a faster approach, before attempting download of a batch of urls, we will set each url as a key in the redis cache ( different db from sidekiq ) with 1 as the value. 

Before actually downloading an image, we will check if we have already attempted downloading this image by checking the cache. If it exists in the cache with 1 as its value will skip reattempting this download.

The UrlCacher provides 3 public methods

 - set_download_attempted(urls)
	This method takes in an array of urls and uses `mapped_mset` method to set multiple urls at once in the cache. 
 
 - remove_attempted_urls(urls)
	This method takes in an array of urls and removes the urls that are already marked as attempted in the cache. It uses `mapped_mget` to get multiple keys at once. 

- flush_redis_cache
	We only handle duplicates within each run of the rake task. This is why we flush the redis cache at the beginning of each run using this method. 

### ImageDownloader

This service takes in 3 arguments:

 - *url* : The validated image url to be downloaded
 - *path*: The validated directory path where the image is to be saved
 - *max_size_in_mb*: This argument is **optional**. Images that are larger than the size specified by this argument will not be downloaded and an error will be logged. The default max_size_in_mb is 30.0.

Once the file is downloaded into memory/tmp storage, this service will check for three conditions before actually saving it.
	 - Whether the downloaded file is an image.
	 - Whether the downloaded image is lesser than the max_size_in_mb specified
	 - Whether the local disk has enough free space to save this downloaded image.

If any of these conditions are not satisfied an appropriate error will be thrown.
NotAnImageError, ImageTooBigError and OutOfDiskSpaceError are custom error classes written for handling these cases.

Each file is prepended with a random string to avoid filename clashes.
The extension for each image is fetched from the content type and appended to the filename.

If and only if all of the three conditions are satisfied will a image file be saved to the local disk.

### ImageDownloadWorkerJob

This is a sidekiq worker that downloads a given set of urls using the *ImageDownloader* service. It handles and logs exceptions that may arise during the download.

## The main rake task : download_images

The rake task takes in two arguments.

 - *source_file_path* : The path to the .txt file containing whitespace separated image urls.
 - *images_target_path*: The path to the directory where the images are to be saved.

	

 1. The rake task first checks for *source_file_path* and *images_target_path* validity using PathValidator service.
 2. It uses the ImageUrlsFileParser service to fetch the first *n* urls. 
 3. It then flushes the redis cache, the one used for url caching.
 4. Inside a loop, it will filter invalid urls using the UrlValidatorService.
 5. It will also urls that were already downloaded(attempted) using the UrlCacheService.
 6. Once it has unique, valid urls, these will passed to a sidekiq worker which in turn calls the ImageDownloader service in order to actually download the image.
 7. If there are 100 urls and the batch_size is 50, there will be two sidekiq workers running parallel to each other. If there are 200 urls then there will be 4 workers running concurrently.
 8. The ImageUrlsFileParser service will return an empty list of urls once it reaches end of file and this when the loop will exit.
 9. We keep track of the rejected invalid urls and print them at the end.


### Test Coverage
I have covered all exceptions and services with essential but minimal test cases.
Given more time, more test cases can be added. The rake task is not covered with test cases.

### Advantages of this solution:

- Really quick, since it uses the cache to avoid duplicate download attempts and sidekiq to download images concurrently.
- It pre-validates and pre-caches the urls before sending them to the worker.

### Drawbacks of this solution:

 - Sidekiq and redis dependency.
 - Urls that cause errors are only logged and the user cannot view a complete list in one place.
 - Race conditions that may let some duplicate url's slip through the cracks.

### Improvements
 
 - More test coverage
 - Using a library like [FastImage](https://github.com/sdsykes/fastimage) to check image size, content type etc before fully downloading the image.
 - Using a library like [Thor](https://github.com/rails/thor) to provide a better CLI interface to run these commands.
 - Assessing the size of the file, ram to dynamically determine the optimal batch size needed for fastest download.
	
