/**
 * GameBanana Official API - Haxe Wrapper
 * 
 * Wrapper for GameBanana's Official API
 * Base URL: https://api.gamebanana.com
 * 
 * @see https://api.gamebanana.com/
 * 
 * @author ImMalloy https://github.com/immalloy
 * 
 * Note: This wrapper covers the Official API which is documented
 * but has fewer endpoints than the Web API (apiv11).
 */

import haxe.Json;

#if HX_NX
import cpp.Pointer;
import haxe.Http;
import haxe.io.Bytes;
import vupx.core.graphics.VpTexture;
import vupx.bindings.sdl2.SDL_Image;
import vupx.bindings.sdl2.SDL_Surface.SDL_SurfaceClass;
import vupx.bindings.sdl2.SDL_RWops.SDL_RWopsClass;
import vupx.bindings.sdl2.SDL_Error;
#else
import haxe.io.Bytes;
import openfl.net.URLLoader;
import openfl.net.URLRequest;
import openfl.net.URLLoaderDataFormat;
import openfl.display.BitmapData;
#end

class GamebananaOfficialAPI
{
	public static inline var BASE_URL = 'https://api.gamebanana.com';

	public var apiKey:String;
	public var appId:String;
	public var userId:String;

	/**
	 * Creates a Gamebanana Official API instance
	 * @param apiKey Your app's API password
	 * @param appId Your app's ID
	 * @param userId Your user ID
	 */
	public function new(?apiKey:String, ?appId:String, ?userId:String)
	{
		this.apiKey = apiKey;
		this.appId = appId;
		this.userId = userId;
	}

	// ============================================
	// CORE - ITEM
	// ============================================

	/**
	 * Get item data
	 * @param itemType Item type (Mod, Game, Tool, etc.)
	 * @param itemId Item ID
	 * @param fields Specific fields to return (comma-separated)
	 * @param onComplete Callback with item data
	 */
	public function getItemData(itemType:String, itemId:Int, ?fields:String, onComplete:Dynamic->Void):Void
	{
		var url = '$BASE_URL/Core/Item/Data?itemtype=$itemType&itemid=$itemId';
		if (fields != null) url += '&fields=$fields';
		url += '&format=json';
		loadRequest(url, onComplete);
	}

	/**
	 * Get allowed fields for an item type
	 * @param itemType Item type
	 * @param onComplete Callback with allowed fields
	 */
	public function getAllowedFields(itemType:String, onComplete:Dynamic->Void):Void
	{
		loadRequest('$BASE_URL/Core/Item/Data/AllowedFields?itemtype=$itemType', onComplete);
	}

	/**
	 * Get allowed item types
	 * @param onComplete Callback with allowed item types
	 */
	public function getAllowedItemTypes(onComplete:Dynamic->Void):Void
	{
		loadRequest('$BASE_URL/Core/Item/Data/AllowedItemTypes', onComplete);
	}

	/**
	 * Verify item exists by ID
	 * @param itemType Item type
	 * @param itemId Item ID
	 * @param onComplete Callback with result
	 */
	public function identifyItemById(itemType:String, itemId:Int, onComplete:Dynamic->Void):Void
	{
		loadRequest('$BASE_URL/Core/Item/IdentifyById?itemtype=$itemType&itemid=$itemId', onComplete);
	}

	// ============================================
	// CORE - LIST
	// ============================================

	/**
	 * List new submissions
	 * @param itemType Item type (Mod, Game, Tool, etc.)
	 * @param gameId Filter by game ID
	 * @param page Page number
	 * @param onComplete Callback with list
	 */
	public function listNew(itemType:String, ?gameId:Int, ?page:Int = 1, onComplete:Dynamic->Void):Void
	{
		var url = '$BASE_URL/Core/List/New?itemtype=$itemType&page=$page&format=json';
		if (gameId != null) url += '&gameid=$gameId';
		loadRequest(url, onComplete);
	}

	/**
	 * Get allowed item types for list
	 * @param onComplete Callback with allowed item types
	 */
	public function getListNewAllowedItemTypes(onComplete:Dynamic->Void):Void
	{
		loadRequest('$BASE_URL/Core/List/New/AllowedItemTypes', onComplete);
	}

	/**
	 * List items by section with filters/sorting
	 * @param itemType Item type
	 * @param section Section name
	 * @param sort Sort field
	 * @param direction Sort direction (asc/desc)
	 * @param page Page number
	 * @param onComplete Callback with list
	 */
	public function listSection(itemType:String, section:String, ?sort:String, ?direction:String = 'desc', ?page:Int = 1, onComplete:Dynamic->Void):Void
	{
		var url = '$BASE_URL/Core/List/Section?itemtype=$itemType&section=$section&page=$page&format=json';
		if (sort != null) url += '&sort=$sort&direction=$direction';
		loadRequest(url, onComplete);
	}

	/**
	 * Get allowed sort fields for an item type
	 * @param itemType Item type
	 * @param onComplete Callback with allowed sorts
	 */
	public function getAllowedSorts(itemType:String, onComplete:Dynamic->Void):Void
	{
		loadRequest('$BASE_URL/Core/List/Section/AllowedSorts?itemtype=$itemType', onComplete);
	}

	/**
	 * Get allowed filter operators
	 * @param filter Filter name
	 * @param onComplete Callback with allowed operators
	 */
	public function getAllowedFilterOperators(filter:String, onComplete:Dynamic->Void):Void
	{
		loadRequest('$BASE_URL/Core/List/Section/AllowedFilterOperators?filter=$filter', onComplete);
	}

	/**
	 * Get allowed filters for an item type
	 * @param itemType Item type
	 * @param onComplete Callback with allowed filters
	 */
	public function getAllowedFilters(itemType:String, onComplete:Dynamic->Void):Void
	{
		loadRequest('$BASE_URL/Core/List/Section/AllowedFilters?itemtype=$itemType', onComplete);
	}

	/**
	 * Get allowed item types for section
	 * @param onComplete Callback with allowed item types
	 */
	public function getSectionAllowedItemTypes(onComplete:Dynamic->Void):Void
	{
		loadRequest('$BASE_URL/Core/List/Section/AllowedItemTypes', onComplete);
	}

	/**
	 * List liked items for a member
	 * @param itemType Item type
	 * @param field Field to match
	 * @param match Match value
	 * @param onComplete Callback with liked items
	 */
	public function listLiked(itemType:String, ?field:String, ?match:String, onComplete:Dynamic->Void):Void
	{
		var url = '$BASE_URL/Core/List/Like?itemtype=$itemType&format=json';
		if (field != null) url += '&field=$field';
		if (match != null) url += '&match=$match';
		loadRequest(url, onComplete);
	}

	/**
	 * Get allowed fields for likes
	 * @param itemType Item type
	 * @param onComplete Callback with allowed fields
	 */
	public function getLikeAllowedFields(itemType:String, onComplete:Dynamic->Void):Void
	{
		loadRequest('$BASE_URL/Core/List/Like/AllowedFields?itemtype=$itemType', onComplete);
	}

	/**
	 * Get allowed item types for likes
	 * @param onComplete Callback with allowed item types
	 */
	public function getLikeAllowedItemTypes(onComplete:Dynamic->Void):Void
	{
		loadRequest('$BASE_URL/Core/List/Like/AllowedItemTypes', onComplete);
	}

	// ============================================
	// CORE - MEMBER
	// ============================================

	/**
	 * Search for members by username
	 * @param username Username to search
	 * @param onComplete Callback with member results
	 */
	public function matchMember(username:String, onComplete:Dynamic->Void):Void
	{
		loadRequest('$BASE_URL/Core/Member/Match?name=${urlEncode(username)}', onComplete);
	}

	/**
	 * Get member ID by username
	 * @param username Username
	 * @param onComplete Callback with member ID
	 */
	public function identifyMember(username:String, onComplete:Dynamic->Void):Void
	{
		loadRequest('$BASE_URL/Core/Member/Identify?name=${urlEncode(username)}', onComplete);
	}

	/**
	 * Get username by member ID
	 * @param userId User ID
	 * @param onComplete Callback with username
	 */
	public function identifyMemberById(userId:Int, onComplete:Dynamic->Void):Void
	{
		loadRequest('$BASE_URL/Core/Member/IdentifyById?userid=$userId', onComplete);
	}

	// ============================================
	// CORE - APP AUTHENTICATION
	// ============================================

	/**
	 * Authenticate an app
	 * @param apiPassword Your app's API password
	 * @param appId Your app's ID
	 * @param userId The user ID
	 * @param onComplete Callback with auth result
	 */
	public function authenticateApp(apiPassword:String, appId:Int, userId:Int, onComplete:Dynamic->Void):Void
	{
		loadRequest('$BASE_URL/Core/App/Authenticate?api_password=${urlEncode(apiPassword)}&app_id=$appId&userid=$userId', onComplete);
	}

	// ============================================
	// RSS
	// ============================================

	/**
	 * Get featured submissions RSS
	 * @param itemType Item type filter
	 * @param onComplete Callback with featured items
	 */
	public function getRssFeatured(?itemType:String, onComplete:Dynamic->Void):Void
	{
		var url = '$BASE_URL/Rss/Featured?format=json';
		if (itemType != null) url += '&itemtype=$itemType';
		loadRequest(url, onComplete);
	}

	/**
	 * Get allowed item types for RSS featured
	 * @param onComplete Callback with allowed types
	 */
	public function getRssFeaturedAllowedItemTypes(onComplete:Dynamic->Void):Void
	{
		loadRequest('$BASE_URL/Rss/Featured/AllowedItemTypes', onComplete);
	}

	/**
	 * Get new submissions RSS
	 * @param itemType Item type filter
	 * @param onComplete Callback with new items
	 */
	public function getRssNew(?itemType:String, onComplete:Dynamic->Void):Void
	{
		var url = '$BASE_URL/Rss/New?format=json';
		if (itemType != null) url += '&itemtype=$itemType';
		loadRequest(url, onComplete);
	}

	/**
	 * Get allowed item types for RSS new
	 * @param onComplete Callback with allowed types
	 */
	public function getRssNewAllowedItemTypes(onComplete:Dynamic->Void):Void
	{
		loadRequest('$BASE_URL/Rss/New/AllowedItemTypes', onComplete);
	}

	// ============================================
	// HELPER: DOWNLOAD
	// ============================================

	/**
	 * Download a file from URL
	 * @param url Direct URL to file
	 * @param onComplete Callback with bytes
	 */
	public function downloadFile(url:String, onComplete:Bytes->Void):Void
	{
		#if HX_NX
		var http = new Http(url);
		http.onError = function(error:String)
		{
			if (onError != null)
				onError('Download Error: $error');
		};
		http.onBytes = function(bytes:Bytes)
		{
			onComplete(bytes);
		};
		http.request(false);
		#else
		var loader:URLLoader = new URLLoader();
		loader.dataFormat = URLLoaderDataFormat.BINARY;
		loader.addEventListener('complete', function(e)
		{
			onComplete(loader.data);
		});
		loader.addEventListener('ioError', function(e)
		{
			if (onError != null)
				onError(e);
		});
		loader.load(new URLRequest(url));
		#end
	}

	/**
	 * Download and create BitmapData from image URL
	 * @param imageUrl URL of image
	 * @param onComplete Callback with BitmapData/VpTexture
	 */
	public function downloadImage(imageUrl:String, onComplete:#if HX_NX VpTexture #else BitmapData #end->Void):Void
	{
		#if HX_NX
		downloadFile(imageUrl, function(bytes:Bytes) {
			var texture = createTextureFromBytes(bytes);
			if (texture != null) {
				onComplete(texture);
			} else {
				if (onError != null)
					onError("Failed to create texture");
			}
		});
		#else
		downloadFile(imageUrl, function(bytes:Bytes) {
			try {
				onComplete(BitmapData.fromBytes(bytes));
			} catch (e:Dynamic) {
				if (onError != null)
					onError('Error creating BitmapData: $e');
			}
		});
		#end
	}

	// ============================================
	// PRIVATE HELPERS
	// ============================================

	public var onError:String->Void;

	private function urlEncode(str:String):String
	{
		return StringTools.urlEncode(str);
	}

	#if HX_NX
	private function createTextureFromBytes(bytes:Bytes):Null<VpTexture>
	{
		try
		{
			var data = Pointer.arrayElem(bytes.getData(), 0);
			var rw = SDL_RWopsClass.SDL_RWFromConstMem(cast data, bytes.length);

			if (rw == null)
			{
				if (onError != null)
					onError("Failed to create SDL_RWops");
				return null;
			}

			var surface = SDL_Image.IMG_Load_RW(rw, 1);

			if (surface == null)
			{
				if (onError != null)
					onError('Failed to decode image: ${SDL_Image.IMG_GetError()}');
				return null;
			}

			var texture = VpTexture.loadFromSDLSurfaceFixed(surface);
			SDL_SurfaceClass.SDL_FreeSurface(surface);
			return texture;
		}
		catch (e:Dynamic)
		{
			if (onError != null)
				onError('Error creating texture: $e');
			return null;
		}
	}
	#end

	private function loadRequest(url:String, onComplete:Dynamic->Void)
	{
		#if HX_NX
		var http = new Http(url);
		http.onError = function(error:String)
		{
			if (onError != null)
				onError('HTTP Error: $error');
		};
		http.onData = function(data:String)
		{
			try
			{
				onComplete(Json.parse(data));
			}
			catch (e:Dynamic)
			{
				if (onError != null)
					onError(e);
			}
		};
		http.request(false);
		#else
		var loader:URLLoader = new URLLoader();
		loader.dataFormat = URLLoaderDataFormat.TEXT;
		loader.addEventListener('complete', function(e)
		{
			try
			{
				onComplete(Json.parse(loader.data));
			}
			catch (e:Dynamic)
			{
				if (onError != null)
					onError(e);
			}
		});
		loader.addEventListener('ioError', function(e)
		{
			if (onError != null)
				onError(e);
		});
		loader.load(new URLRequest(url));
		#end
	}
}
