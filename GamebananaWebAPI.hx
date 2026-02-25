/**
 * GameBanana Web API (apiv11) - Complete Haxe Wrapper
 * 
 * Full wrapper for GameBanana's internal Web API v11
 * Base URL: https://gamebanana.com/apiv11
 * 
 * @author ImMalloy https://github.com/immalloy
 * 
 * GameBanana API Documentation:
 * @see https://gamebanana.com/apiv11
 * 
 * Note: This wrapper focuses on the Web API (apiv11) which is undocumented
 * but provides more detailed data than the Official API.
 * Most read operations don't require authentication.
 * Some endpoints marked with [Auth] require authentication.
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

class GamebananaAPI
{
	public static inline var BASE_URL = 'https://gamebanana.com/apiv11';

	public var apiKey:String;
	public var userId:String;
	public var authToken:String;

	/**
	 * Creates a Gamebanana Web API instance
	 * Most read operations don't require authentication
	 * @param apiKey Optional API Key for authenticated endpoints
	 * @param userId Optional User ID
	 */
	public function new(?apiKey:String, ?userId:String)
	{
		this.apiKey = apiKey;
		this.userId = userId;
		this.authToken = null;
	}

	// ============================================
	// SECTION 1: SEARCH & DISCOVERY
	// ============================================

	/**
	 * Get search results
	 * @param query Search query (min 2 characters)
	 * @param modelName Filter by model type (Mod, Game, Member, etc.)
	 * @param order Sort order (newest, popularity, best_match, etc.)
	 * @param page Page number
	 * @param perPage Results per page (max 50)
	 */
	public function search(query:String, ?modelName:String = 'Mod', ?order:String = 'newest', ?page:Int = 1, ?perPage:Int = 25, onComplete:Dynamic->Void):Void
	{
		var url = '$BASE_URL/Util/Search/Results';
		url += '?_sSearchString=${urlEncode(query)}';
		url += '&_sModelName=$modelName';
		url += '&_sOrder=$order';
		url += '&_nPage=$page';
		url += '&_nPerpage=$perPage';
		loadRequest(url, onComplete);
	}

	/**
	 * Get search suggestions
	 * @param query Search query (min 2 characters)
	 * @param modelName Narrow to specific section
	 */
	public function getSearchSuggestions(query:String, ?modelName:String, onComplete:Dynamic->Void):Void
	{
		var url = '$BASE_URL/Util/Search/Suggestions';
		url += '?_sSearchString=${urlEncode(query)}';
		if (modelName != null) url += '&_sModelName=$modelName';
		loadRequest(url, onComplete);
	}

	/**
	 * Get games by name
	 * @param name Search query (min 3 characters)
	 * @param page Page number
	 * @param perPage Results per page
	 */
	public function getGamesByName(name:String, ?page:Int = 1, ?perPage:Int = 5, onComplete:Dynamic->Void):Void
	{
		var url = '$BASE_URL/Util/Game/NameMatch';
		url += '?_sName=${urlEncode(name)}';
		url += '&_nPage=$page';
		url += '&_nPerpage=$perPage';
		loadRequest(url, onComplete);
	}

	/**
	 * Get tags by text
	 * @param tag Search query (min 2 characters)
	 */
	public function getTagsByText(tag:String, onComplete:Dynamic->Void):Void
	{
		var url = '$BASE_URL/Util/Generic/Tags';
		url += '?_sTag=${urlEncode(tag)}';
		loadRequest(url, onComplete);
	}

	/**
	 * Get latest submissions from all games
	 */
	public function getLatestGlobal(?page:Int = 1, ?perPage:Int = 25, onComplete:Dynamic->Void):Void
	{
		var url = '$BASE_URL/Util/Homepage/Submissions';
		url += '?_nPage=$page';
		url += '&_nPerpage=$perPage';
		loadRequest(url, onComplete);
	}

	/**
	 * Get featured submissions
	 * @param gameId Optional game ID to filter
	 */
	public function getFeatured(?gameId:Int, ?page:Int = 1, onComplete:Dynamic->Void):Void
	{
		var url = gameId != null 
			? '$BASE_URL/Util/List/Featured?_idGameRow=$gameId&_nPage=$page'
			: '$BASE_URL/Util/List/Featured';
		loadRequest(url, onComplete);
	}

	/**
	 * Get trending/classic/new games
	 */
	public function getHomepageGames(onComplete:Dynamic->Void):Void
	{
		loadRequest('$BASE_URL/Util/Homepage/TopGames', onComplete);
	}

	/**
	 * Get homepage features
	 */
	public function getHomepageFeatures(onComplete:Dynamic->Void):Void
	{
		loadRequest('$BASE_URL/Util/Homepage/Features', onComplete);
	}

	/**
	 * Get community spotlight (global)
	 */
	public function getCommunitySpotlight(onComplete:Dynamic->Void):Void
	{
		loadRequest('$BASE_URL/Util/Homepage/CommunitySpotlight', onComplete);
	}

	/**
	 * Get list filter config for a model
	 * @param modelName Model name (Mod, Game, Tool, etc.)
	 */
	public function getListFilterConfig(modelName:String, onComplete:Dynamic->Void):Void
	{
		loadRequest('$BASE_URL/$modelName/ListFilterConfig', onComplete);
	}

	/**
	 * Get latest by model type with filters
	 * @param modelName Model name
	 * @param page Page number
	 * @param perPage Results per page
	 * @param sort Sort option
	 * @param filters Additional filters
	 */
	public function getIndex(modelName:String, ?page:Int = 1, ?perPage:Int = 5, ?sort:String = null, ?filters:Map<String, String>, onComplete:Dynamic->Void):Void
	{
		var url = '$BASE_URL/$modelName/Index';
		url += '?_nPage=$page';
		url += '&_nPerpage=$perPage';
		if (sort != null) url += '&_sSort=$sort';
		if (filters != null) {
			for (key in filters.keys()) {
				url += '&_aFilters[$key]=${filters.get(key)}';
			}
		}
		loadRequest(url, onComplete);
	}

	// ============================================
	// SECTION 2: GAMES
	// ============================================

	/**
	 * Get game profile page
	 * @param gameId Game ID
	 */
	public function getGameProfilePage(gameId:Int, onComplete:Dynamic->Void):Void
	{
		loadRequest('$BASE_URL/Game/$gameId/ProfilePage', onComplete);
	}

	/**
	 * Get game multiple properties
	 * @param gameId Game ID
	 * @param properties Comma-separated properties
	 */
	public function getGameProperties(gameId:Int, ?properties:String, onComplete:Dynamic->Void):Void
	{
		var url = '$BASE_URL/Game/$gameId';
		if (properties != null) url += '?_csvProperties=$properties';
		loadRequest(url, onComplete);
	}

	/**
	 * Get game detailed info
	 * @param gameId Game ID
	 */
	public function getGameInfo(gameId:Int, onComplete:Dynamic->Void):Void
	{
		loadRequest('$BASE_URL/Game/$gameId/GetStartedPage', onComplete);
	}

	/**
	 * Get game rules
	 * @param gameId Game ID
	 */
	public function getGameRules(gameId:Int, onComplete:Dynamic->Void):Void
	{
		loadRequest('$BASE_URL/Game/$gameId/Rules', onComplete);
	}

	/**
	 * Get latest submissions for a game
	 * @param gameId Game ID
	 * @param page Page number
	 * @param sort Sort type (default, new, updated)
	 * @param name Search query
	 */
	public function getGameSubfeed(gameId:Int, ?page:Int = 1, ?sort:String = 'default', ?name:String, onComplete:Dynamic->Void):Void
	{
		var url = '$BASE_URL/Game/$gameId/Subfeed';
		url += '?_nPage=$page';
		url += '&_sSort=$sort';
		if (name != null) url += '&_sName=${urlEncode(name)}';
		loadRequest(url, onComplete);
	}

	/**
	 * Get top submissions for a game
	 * @param gameId Game ID
	 * @param period Time period (day, week, month, 3 months, 6 months, year, all time)
	 */
	public function getGameTopSubs(gameId:Int, ?period:String = 'all time', onComplete:Dynamic->Void):Void
	{
		loadRequest('$BASE_URL/Game/$gameId/TopSubs', onComplete);
	}

	/**
	 * Get game community spotlight
	 * @param gameId Game ID
	 */
	public function getGameCommunitySpotlight(gameId:Int, onComplete:Dynamic->Void):Void
	{
		loadRequest('$BASE_URL/Game/$gameId/CommunitySpotlight', onComplete);
	}

	/**
	 * Get discussions for a game
	 * @param gameId Game ID
	 * @param page Page number
	 */
	public function getGameDiscussions(gameId:Int, ?page:Int = 1, onComplete:Dynamic->Void):Void
	{
		var url = '$BASE_URL/Util/Generic/Discussions';
		url += '?_idGameRow=$gameId';
		url += '&_nPage=$page';
		loadRequest(url, onComplete);
	}

	// ============================================
	// SECTION 3: WORK IN PROGRESS
	// ============================================

	/**
	 * Get categories for a section
	 * @param sectionSlug Section slug (Mod, Tool, Game, etc.)
	 * @param sort Sort by (a_to_z, count)
	 */
	public function getCategories(sectionSlug:String, ?sort:String = 'a_to_z', onComplete:Dynamic->Void):Void
	{
		var url = '$BASE_URL/$sectionSlug/Categories';
		url += '?_sSort=$sort';
		loadRequest(url, onComplete);
	}

	/**
	 * Get subcategories for a root category
	 * @param rootCategoryId Root category ID
	 */
	public function getSubCategories(rootCategoryId:Int, onComplete:Dynamic->Void):Void
	{
		loadRequest('$BASE_URL/ModCategory/$rootCategoryId/SubCategories', onComplete);
	}

	/**
	 * Get member's awarded bounties
	 * @param memberId Member ID
	 */
	public function getMemberAwardedBounties(memberId:Int, onComplete:Dynamic->Void):Void
	{
		loadRequest('$BASE_URL/Member/$memberId/AwardedBounties', onComplete);
	}

	/**
	 * Get member's contributed bounties
	 * @param memberId Member ID
	 */
	public function getMemberContributedBounties(memberId:Int, onComplete:Dynamic->Void):Void
	{
		loadRequest('$BASE_URL/Member/$memberId/ContributedBounties', onComplete);
	}

	/**
	 * Get member's liked submissions
	 * @param memberId Member ID
	 */
	public function getMemberLikedSubmissions(memberId:Int, onComplete:Dynamic->Void):Void
	{
		loadRequest('$BASE_URL/Member/$memberId/LikedSubmissions', onComplete);
	}

	/**
	 * Get member's medals
	 * @param memberId Member ID
	 */
	public function getMemberMedals(memberId:Int, onComplete:Dynamic->Void):Void
	{
		loadRequest('$BASE_URL/Member/$memberId/Medals', onComplete);
	}

	/**
	 * Get member's participated contests
	 * @param memberId Member ID
	 */
	public function getMemberParticipatedContests(memberId:Int, onComplete:Dynamic->Void):Void
	{
		loadRequest('$BASE_URL/Member/$memberId/ParticipatedContests', onComplete);
	}

	/**
	 * Get member's rated ideas
	 * @param memberId Member ID
	 */
	public function getMemberRatedIdeas(memberId:Int, onComplete:Dynamic->Void):Void
	{
		loadRequest('$BASE_URL/Member/$memberId/RatedIdeas', onComplete);
	}

	/**
	 * Get member's solved questions
	 * @param memberId Member ID
	 */
	public function getMemberSolvedQuestions(memberId:Int, onComplete:Dynamic->Void):Void
	{
		loadRequest('$BASE_URL/Member/$memberId/SolvedQuestions', onComplete);
	}

	/**
	 * Get member's thanked submissions
	 * @param memberId Member ID
	 */
	public function getMemberThankedSubmissions(memberId:Int, onComplete:Dynamic->Void):Void
	{
		loadRequest('$BASE_URL/Member/$memberId/ThankedSubmissions', onComplete);
	}

	/**
	 * Get member's voted polls
	 * @param memberId Member ID
	 */
	public function getMemberVotedPolls(memberId:Int, onComplete:Dynamic->Void):Void
	{
		loadRequest('$BASE_URL/Member/$memberId/VotedPolls', onComplete);
	}

	/**
	 * Get member's submissions where credited
	 * @param memberId Member ID
	 */
	public function getMemberContributions(memberId:Int, onComplete:Dynamic->Void):Void
	{
		loadRequest('$BASE_URL/Member/$memberId/Submissions/Contributions', onComplete);
	}

	/**
	 * Get member's latest posts
	 * @param memberId Member ID
	 */
	public function getMemberPosts(memberId:Int, onComplete:Dynamic->Void):Void
	{
		loadRequest('$BASE_URL/Member/$memberId/Submissions/Posts', onComplete);
	}

	/**
	 * Get member's subfeed
	 * @param memberId Member ID
	 */
	public function getMemberSubfeed(memberId:Int, onComplete:Dynamic->Void):Void
	{
		loadRequest('$BASE_URL/Member/$memberId/SubFeed', onComplete);
	}

	// ============================================
	// SECTION 4: AUTHENTICATION
	// ============================================

	/**
	 * Authenticate via username
	 * @param username Username
	 * @param password Password
	 */
	public function authenticate(username:String, password:String, onComplete:Dynamic->Void):Void
	{
		postRequest('$BASE_URL/Member/Authenticate', {
			username: username,
			password: password
		}, onComplete);
	}

	/**
	 * Request confirmation code via email
	 * @param email Email address
	 */
	public function requestEmailAuth(email:String, onComplete:Dynamic->Void):Void
	{
		postRequest('$BASE_URL/Member/EmailAuthenticate', {
			email: email
		}, onComplete);
	}

	/**
	 * Submit confirmation code
	 * @param email Email address
	 * @param code Confirmation code
	 */
	public function confirmEmailAuth(email:String, code:String, onComplete:Dynamic->Void):Void
	{
		postRequest('$BASE_URL/Member/EmailAuthenticate', {
			email: email,
			code: code
		}, onComplete);
	}

	// ============================================
	// SECTION 5: SUBMISSION - BASE
	// ============================================

	/**
	 * Get submission properties
	 * @param sectionSlug Section slug (Mod, Tool, etc.)
	 * @param submissionId Submission ID
	 * @param properties Comma-separated properties to fetch
	 */
	public function getSubmissionProperties(sectionSlug:String, submissionId:Int, ?properties:String, onComplete:Dynamic->Void):Void
	{
		var url = '$BASE_URL/$sectionSlug/$submissionId';
		if (properties != null) url += '?_csvProperties=$properties';
		loadRequest(url, onComplete);
	}

	/**
	 * Get submission profile page
	 * @param sectionSlug Section slug
	 * @param submissionId Submission ID
	 */
	public function getSubmissionProfilePage(sectionSlug:String, submissionId:Int, onComplete:Dynamic->Void):Void
	{
		loadRequest('$BASE_URL/$sectionSlug/$submissionId/ProfilePage', onComplete);
	}

	/**
	 * Get submission download page
	 * @param sectionSlug Section slug
	 * @param submissionId Submission ID
	 */
	public function getSubmissionDownloadPage(sectionSlug:String, submissionId:Int, onComplete:Dynamic->Void):Void
	{
		loadRequest('$BASE_URL/$sectionSlug/$submissionId/DownloadPage', onComplete);
	}

	/**
	 * Get submission files
	 * @param sectionSlug Section slug
	 * @param submissionId Submission ID
	 */
	public function getSubmissionFiles(sectionSlug:String, submissionId:Int, onComplete:Dynamic->Void):Void
	{
		loadRequest('$BASE_URL/$sectionSlug/$submissionId/Files', onComplete);
	}

	/**
	 * Get submission updates
	 * @param sectionSlug Section slug
	 * @param submissionId Submission ID
	 * @param page Page number
	 * @param perPage Results per page
	 */
	public function getSubmissionUpdates(sectionSlug:String, submissionId:Int, ?page:Int = 1, ?perPage:Int = 20, onComplete:Dynamic->Void):Void
	{
		var url = '$BASE_URL/$sectionSlug/$submissionId/Updates';
		url += '?_nPage=$page';
		url += '&_nPerpage=$perPage';
		loadRequest(url, onComplete);
	}

	/**
	 * Get submission collections
	 * @param sectionSlug Section slug
	 * @param submissionId Submission ID
	 * @param page Page number
	 */
	public function getSubmissionCollections(sectionSlug:String, submissionId:Int, ?page:Int = 1, onComplete:Dynamic->Void):Void
	{
		var url = '$BASE_URL/$sectionSlug/$submissionId/Collections';
		url += '?_nPage=$page';
		loadRequest(url, onComplete);
	}

	/**
	 * Get submission accessor collections
	 * @param sectionSlug Section slug
	 * @param submissionId Submission ID
	 */
	public function getSubmissionAccessorCollections(sectionSlug:String, submissionId:Int, onComplete:Dynamic->Void):Void
	{
		loadRequest('$BASE_URL/$sectionSlug/$submissionId/AccessorCollections', onComplete);
	}

	/**
	 * [Auth] Add submission to collection
	 * @param sectionSlug Section slug
	 * @param submissionId Submission ID
	 * @param collectionId Collection ID
	 */
	public function addToCollection(sectionSlug:String, submissionId:Int, collectionId:Int, onComplete:Dynamic->Void):Void
	{
		postRequest('$BASE_URL/$sectionSlug/$submissionId/AddToCollection', {
			collection_id: collectionId
		}, onComplete);
	}

	/**
	 * [Auth] Remove submission from collection
	 * @param sectionSlug Section slug
	 * @param submissionId Submission ID
	 * @param collectionId Collection ID
	 */
	public function removeFromCollection(sectionSlug:String, submissionId:Int, collectionId:Int, onComplete:Dynamic->Void):Void
	{
		deleteRequest('$BASE_URL/$sectionSlug/$submissionId/RemoveFromCollection', {
			collection_id: collectionId
		}, onComplete);
	}

	/**
	 * Get submission embeddables
	 * @param sectionSlug Section slug
	 * @param submissionId Submission ID
	 */
	public function getSubmissionEmbeddables(sectionSlug:String, submissionId:Int, onComplete:Dynamic->Void):Void
	{
		loadRequest('$BASE_URL/$sectionSlug/$submissionId/EmbeddablesPage', onComplete);
	}

	/**
	 * Get submission issues
	 * @param sectionSlug Section slug
	 * @param submissionId Submission ID
	 * @param page Page number
	 */
	public function getSubmissionIssues(sectionSlug:String, submissionId:Int, ?page:Int = 1, onComplete:Dynamic->Void):Void
	{
		var url = '$BASE_URL/$sectionSlug/$submissionId/Issues';
		url += '?_nPage=$page';
		loadRequest(url, onComplete);
	}

	/**
	 * [Auth] Add an issue
	 * @param sectionSlug Section slug
	 * @param submissionId Submission ID
	 * @param title Issue title
	 * @param description Issue description
	 */
	public function addIssue(sectionSlug:String, submissionId:Int, title:String, description:String, onComplete:Dynamic->Void):Void
	{
		postRequest('$BASE_URL/$sectionSlug/$submissionId/Issue/Add', {
			title: title,
			description: description
		}, onComplete);
	}

	/**
	 * Get submission likes count
	 * @param sectionSlug Section slug
	 * @param submissionId Submission ID
	 */
	public function getSubmissionLikesCount(sectionSlug:String, submissionId:Int, onComplete:Dynamic->Void):Void
	{
		loadRequest('$BASE_URL/$sectionSlug/$submissionId?_csvProperties=_nLikeCount', onComplete);
	}

	/**
	 * Get users who liked submission
	 * @param sectionSlug Section slug
	 * @param submissionId Submission ID
	 * @param page Page number
	 */
	public function getSubmissionLikes(sectionSlug:String, submissionId:Int, ?page:Int = 1, onComplete:Dynamic->Void):Void
	{
		var url = '$BASE_URL/$sectionSlug/$submissionId/Likes';
		url += '?_nPage=$page';
		loadRequest(url, onComplete);
	}

	/**
	 * [Auth] Like submission
	 * @param sectionSlug Section slug
	 * @param submissionId Submission ID
	 */
	public function likeSubmission(sectionSlug:String, submissionId:Int, onComplete:Dynamic->Void):Void
	{
		postRequest('$BASE_URL/$sectionSlug/$submissionId/Like', {}, onComplete);
	}

	/**
	 * [Auth] Unlike submission
	 * @param sectionSlug Section slug
	 * @param submissionId Submission ID
	 */
	public function unlikeSubmission(sectionSlug:String, submissionId:Int, onComplete:Dynamic->Void):Void
	{
		deleteRequest('$BASE_URL/$sectionSlug/$submissionId/Like', {}, onComplete);
	}

	/**
	 * Get submission posts count
	 * @param sectionSlug Section slug
	 * @param submissionId Submission ID
	 */
	public function getSubmissionPostsCount(sectionSlug:String, submissionId:Int, onComplete:Dynamic->Void):Void
	{
		loadRequest('$BASE_URL/$sectionSlug/$submissionId?_csvProperties=_nPostCount', onComplete);
	}

	/**
	 * Get submission posts feed
	 * @param sectionSlug Section slug
	 * @param submissionId Submission ID
	 * @param page Page number
	 * @param perPage Results per page
	 * @param sort Sort order
	 */
	public function getSubmissionPosts(sectionSlug:String, submissionId:Int, ?page:Int = 1, ?perPage:Int = 20, ?sort:String = 'date', onComplete:Dynamic->Void):Void
	{
		var url = '$BASE_URL/$sectionSlug/$submissionId/Posts';
		url += '?_nPage=$page';
		url += '&_nPerpage=$perPage';
		url += '&_sSort=$sort';
		loadRequest(url, onComplete);
	}

	/**
	 * [Auth] Add a post/reply
	 * @param sectionSlug Section slug
	 * @param submissionId Submission ID
	 * @param content Post content
	 */
	public function addPost(sectionSlug:String, submissionId:Int, content:String, onComplete:Dynamic->Void):Void
	{
		postRequest('$BASE_URL/$sectionSlug/$submissionId/Post/Add', {
			content: content
		}, onComplete);
	}

	/**
	 * Get submission subscribers count
	 * @param sectionSlug Section slug
	 * @param submissionId Submission ID
	 */
	public function getSubmissionSubscribersCount(sectionSlug:String, submissionId:Int, onComplete:Dynamic->Void):Void
	{
		loadRequest('$BASE_URL/$sectionSlug/$submissionId?_csvProperties=_nSubscriberCount', onComplete);
	}

	/**
	 * Get users who subscribed
	 * @param sectionSlug Section slug
	 * @param submissionId Submission ID
	 * @param page Page number
	 */
	public function getSubmissionSubscribers(sectionSlug:String, submissionId:Int, ?page:Int = 1, onComplete:Dynamic->Void):Void
	{
		var url = '$BASE_URL/$sectionSlug/$submissionId/Subscribers';
		url += '?_nPage=$page';
		loadRequest(url, onComplete);
	}

	/**
	 * [Auth] Subscribe to submission
	 * @param sectionSlug Section slug
	 * @param submissionId Submission ID
	 */
	public function subscribe(sectionSlug:String, submissionId:Int, onComplete:Dynamic->Void):Void
	{
		postRequest('$BASE_URL/$sectionSlug/$submissionId/Subscription/Add', {}, onComplete);
	}

	/**
	 * Get submission thanks count
	 * @param sectionSlug Section slug
	 * @param submissionId Submission ID
	 */
	public function getSubmissionThanksCount(sectionSlug:String, submissionId:Int, onComplete:Dynamic->Void):Void
	{
		loadRequest('$BASE_URL/$sectionSlug/$submissionId?_csvProperties=_nThankCount', onComplete);
	}

	/**
	 * Get users who thanked
	 * @param sectionSlug Section slug
	 * @param submissionId Submission ID
	 * @param page Page number
	 */
	public function getSubmissionThanks(sectionSlug:String, submissionId:Int, ?page:Int = 1, onComplete:Dynamic->Void):Void
	{
		var url = '$BASE_URL/$sectionSlug/$submissionId/Thanks';
		url += '?_nPage=$page';
		loadRequest(url, onComplete);
	}

	/**
	 * [Auth] Thank submission
	 * @param sectionSlug Section slug
	 * @param submissionId Submission ID
	 */
	public function thankSubmission(sectionSlug:String, submissionId:Int, onComplete:Dynamic->Void):Void
	{
		postRequest('$BASE_URL/$sectionSlug/$submissionId/Thank/Add', {}, onComplete);
	}

	/**
	 * Get submission todos
	 * @param sectionSlug Section slug
	 * @param submissionId Submission ID
	 * @param page Page number
	 */
	public function getSubmissionTodos(sectionSlug:String, submissionId:Int, ?page:Int = 1, onComplete:Dynamic->Void):Void
	{
		var url = '$BASE_URL/$sectionSlug/$submissionId/Todos';
		url += '?_nPage=$page';
		loadRequest(url, onComplete);
	}

	/**
	 * [Auth] Add a todo
	 * @param sectionSlug Section slug
	 * @param submissionId Submission ID
	 * @param content Todo content
	 */
	public function addTodo(sectionSlug:String, submissionId:Int, content:String, onComplete:Dynamic->Void):Void
	{
		postRequest('$BASE_URL/$sectionSlug/$submissionId/Todo/Add', {
			content: content
		}, onComplete);
	}

	/**
	 * Get submission updates count
	 * @param sectionSlug Section slug
	 * @param submissionId Submission ID
	 */
	public function getSubmissionUpdatesCount(sectionSlug:String, submissionId:Int, onComplete:Dynamic->Void):Void
	{
		loadRequest('$BASE_URL/$sectionSlug/$submissionId?_csvProperties=_nUpdateCount', onComplete);
	}

	/**
	 * [Auth] Add an update
	 * @param sectionSlug Section slug
	 * @param submissionId Submission ID
	 * @param title Update title
	 * @param content Update content
	 */
	public function addUpdate(sectionSlug:String, submissionId:Int, title:String, content:String, onComplete:Dynamic->Void):Void
	{
		postRequest('$BASE_URL/$sectionSlug/$submissionId/Update', {
			title: title,
			content: content
		}, onComplete);
	}

	// ============================================
	// SECTION 6: SUBMISSION - SPECIFIC TYPES
	// ============================================

	// --- App ---

	/**
	 * Get app users
	 * @param submissionId App submission ID
	 * @param page Page number
	 */
	public function getAppUsers(submissionId:Int, ?page:Int = 1, onComplete:Dynamic->Void):Void
	{
		var url = '$BASE_URL/App/$submissionId/Users';
		url += '?_nPage=$page';
		loadRequest(url, onComplete);
	}

	/**
	 * Get app custom config
	 * @param submissionId App submission ID
	 * @param configId Config ID
	 */
	public function getAppCustomConfig(submissionId:Int, configId:Int, onComplete:Dynamic->Void):Void
	{
		loadRequest('$BASE_URL/App/$submissionId/CustomConfig/$configId', onComplete);
	}

	// --- Collection ---

	/**
	 * Get collection items
	 * @param submissionId Collection ID
	 * @param page Page number
	 * @param perPage Results per page
	 */
	public function getCollectionItems(submissionId:Int, ?page:Int = 1, ?perPage:Int = 25, onComplete:Dynamic->Void):Void
	{
		var url = '$BASE_URL/Collection/$submissionId/Items';
		url += '?_nPage=$page';
		url += '&_nPerpage=$perPage';
		loadRequest(url, onComplete);
	}

	/**
	 * [Auth] Create a collection
	 * @param name Collection name
	 * @param description Collection description
	 * @param gameId Game ID
	 * @param categoryId Category ID
	 */
	public function createCollection(name:String, ?description:String, ?gameId:Int, ?categoryId:Int, onComplete:Dynamic->Void):Void
	{
		var params:Map<String, Dynamic> = new Map();
		params.set('name', name);
		if (description != null) params.set('description', description);
		if (gameId != null) params.set('game_id', gameId);
		if (categoryId != null) params.set('category_id', categoryId);
		postRequest('$BASE_URL/Collection/Add', params, onComplete);
	}

	// --- Contest ---

	/**
	 * Get contest winners
	 * @param submissionId Contest ID
	 */
	public function getContestWinners(submissionId:Int, onComplete:Dynamic->Void):Void
	{
		loadRequest('$BASE_URL/Contest/$submissionId/Winners', onComplete);
	}

	// --- Idea ---

	/**
	 * Get idea ratings
	 * @param submissionId Idea ID
	 * @param page Page number
	 * @param perPage Results per page
	 */
	public function getIdeaRatings(submissionId:Int, ?page:Int = 1, ?perPage:Int = 25, onComplete:Dynamic->Void):Void
	{
		var url = '$BASE_URL/Idea/$submissionId/Ratings';
		url += '?_nPage=$page';
		url += '&_nPerpage=$perPage';
		loadRequest(url, onComplete);
	}

	// --- Jam ---

	/**
	 * Get jam bounty contributors
	 * @param submissionId Jam ID
	 * @param page Page number
	 */
	public function getJamBountyContributors(submissionId:Int, ?page:Int = 1, onComplete:Dynamic->Void):Void
	{
		var url = '$BASE_URL/Jam/$submissionId/Bounty/Contributors';
		url += '?_nPage=$page';
		loadRequest(url, onComplete);
	}

	/**
	 * Get jam bounty recipients
	 * @param submissionId Jam ID
	 * @param page Page number
	 */
	public function getJamBountyRecipients(submissionId:Int, ?page:Int = 1, onComplete:Dynamic->Void):Void
	{
		var url = '$BASE_URL/Jam/$submissionId/Bounty/Recipients';
		url += '?_nPage=$page';
		loadRequest(url, onComplete);
	}

	/**
	 * Get jam entries
	 * @param submissionId Jam ID
	 * @param page Page number
	 */
	public function getJamEntries(submissionId:Int, ?page:Int = 1, onComplete:Dynamic->Void):Void
	{
		var url = '$BASE_URL/Jam/$submissionId/Entries';
		url += '?_nPage=$page';
		loadRequest(url, onComplete);
	}

	// --- Poll ---

	/**
	 * Get poll votes
	 * @param submissionId Poll ID
	 * @param page Page number
	 * @param perPage Results per page
	 */
	public function getPollVotes(submissionId:Int, ?page:Int = 1, ?perPage:Int = 25, onComplete:Dynamic->Void):Void
	{
		var url = '$BASE_URL/Poll/$submissionId/Votes';
		url += '?_nPage=$page';
		url += '&_nPerpage=$perPage';
		loadRequest(url, onComplete);
	}

	// --- Project ---

	/**
	 * Get project finished works
	 * @param submissionId Project ID
	 * @param page Page number
	 */
	public function getProjectFinishedWorks(submissionId:Int, ?page:Int = 1, onComplete:Dynamic->Void):Void
	{
		var url = '$BASE_URL/Project/$submissionId/FinishedWorks';
		url += '?_nPage=$page';
		loadRequest(url, onComplete);
	}

	/**
	 * Get project WIPs
	 * @param submissionId Project ID
	 * @param page Page number
	 */
	public function getProjectWips(submissionId:Int, ?page:Int = 1, onComplete:Dynamic->Void):Void
	{
		var url = '$BASE_URL/Project/$submissionId/Wips';
		url += '?_nPage=$page';
		loadRequest(url, onComplete);
	}

	// --- Request ---

	/**
	 * Get request bounty recipients
	 * @param submissionId Request ID
	 * @param page Page number
	 */
	public function getRequestBountyRecipients(submissionId:Int, ?page:Int = 1, onComplete:Dynamic->Void):Void
	{
		var url = '$BASE_URL/Request/$submissionId/BountyRecipients';
		url += '?_nPage=$page';
		loadRequest(url, onComplete);
	}

	/**
	 * Get request bounty contributors
	 * @param submissionId Request ID
	 * @param page Page number
	 */
	public function getRequestBountyContributors(submissionId:Int, ?page:Int = 1, onComplete:Dynamic->Void):Void
	{
		var url = '$BASE_URL/Request/$submissionId/Bounty/Contributors';
		url += '?_nPage=$page';
		loadRequest(url, onComplete);
	}

	// ============================================
	// SECTION 7: RIPE
	// ============================================

	/**
	 * Get Ripe info
	 */
	public function getRipeInfo(onComplete:Dynamic->Void):Void
	{
		loadRequest('$BASE_URL/Ripe/Info', onComplete);
	}

	/**
	 * Get latest Ripe purchasers
	 */
	public function getRipePurchasers(onComplete:Dynamic->Void):Void
	{
		loadRequest('$BASE_URL/Ripe/Purchasers', onComplete);
	}

	// ============================================
	// SECTION 8: DICTIONARIES
	// ============================================

	/**
	 * Get trash reasons
	 */
	public function getTrashReasons(onComplete:Dynamic->Void):Void
	{
		loadRequest('$BASE_URL/Util/Config/TrashReasons', onComplete);
	}

	// ============================================
	// SECTION 9: POST/REPLY ENDPOINTS
	// ============================================

	/**
	 * Get post/reply properties
	 * @param postId Post ID
	 */
	public function getPostProfilePage(postId:Int, onComplete:Dynamic->Void):Void
	{
		loadRequest('$BASE_URL/Post/$postId/ProfilePage', onComplete);
	}

	/**
	 * [Auth] Add a reply to post
	 * @param postId Post ID
	 * @param content Reply content
	 */
	public function addReply(postId:Int, content:String, onComplete:Dynamic->Void):Void
	{
		postRequest('$BASE_URL/Post/$postId', {
			content: content
		}, onComplete);
	}

	/**
	 * [Auth] Trash a post/reply
	 * @param postId Post ID
	 */
	public function trashPost(postId:Int, onComplete:Dynamic->Void):Void
	{
		deleteRequest('$BASE_URL/Post/$postId', {}, onComplete);
	}

	/**
	 * [Auth] Untrash a post/reply
	 * @param postId Post ID
	 */
	public function untrashPost(postId:Int, onComplete:Dynamic->Void):Void
	{
		patchRequest('$BASE_URL/Post/$postId/Untrash', {}, onComplete);
	}

	// ============================================
	// SECTION 10: ISSUE ENDPOINTS
	// ============================================

	/**
	 * [Auth] Edit an issue
	 * @param issueId Issue ID
	 * @param title New title
	 * @param description New description
	 */
	public function editIssue(issueId:Int, title:String, description:String, onComplete:Dynamic->Void):Void
	{
		patchRequest('$BASE_URL/Issue/$issueId', {
			title: title,
			description: description
		}, onComplete);
	}

	/**
	 * [Auth] Trash an issue
	 * @param issueId Issue ID
	 */
	public function trashIssue(issueId:Int, onComplete:Dynamic->Void):Void
	{
		deleteRequest('$BASE_URL/Issue/$issueId', {}, onComplete);
	}

	// ============================================
	// SECTION 11: TODO ENDPOINTS
	// ============================================

	/**
	 * [Auth] Edit a todo
	 * @param todoId Todo ID
	 * @param content New content
	 */
	public function editTodo(todoId:Int, content:String, onComplete:Dynamic->Void):Void
	{
		patchRequest('$BASE_URL/Todo/$todoId', {
			content: content
		}, onComplete);
	}

	/**
	 * [Auth] Toggle todo state
	 * @param todoId Todo ID
	 */
	public function toggleTodo(todoId:Int, onComplete:Dynamic->Void):Void
	{
		patchRequest('$BASE_URL/Todo/$todoId/Toggle', {}, onComplete);
	}

	/**
	 * [Auth] Trash a todo
	 * @param todoId Todo ID
	 */
	public function trashTodo(todoId:Int, onComplete:Dynamic->Void):Void
	{
		deleteRequest('$BASE_URL/Todo/$todoId', {}, onComplete);
	}

	// ============================================
	// SECTION 12: UPDATE ENDPOINTS
	// ============================================

	/**
	 * [Auth] Edit an update
	 * @param updateId Update ID
	 * @param title New title
	 * @param content New content
	 */
	public function editUpdate(updateId:Int, title:String, content:String, onComplete:Dynamic->Void):Void
	{
		patchRequest('$BASE_URL/Update/$updateId', {
			title: title,
			content: content
		}, onComplete);
	}

	/**
	 * [Auth] Trash an update
	 * @param updateId Update ID
	 */
	public function trashUpdate(updateId:Int, onComplete:Dynamic->Void):Void
	{
		deleteRequest('$BASE_URL/Update/$updateId', {}, onComplete);
	}

	/**
	 * [Auth] Untrash an update
	 * @param updateId Update ID
	 */
	public function untrashUpdate(updateId:Int, onComplete:Dynamic->Void):Void
	{
		patchRequest('$BASE_URL/Update/$updateId/Untrash', {}, onComplete);
	}

	// ============================================
	// SECTION 13: SUBSCRIPTION ENDPOINTS
	// ============================================

	/**
	 * [Auth] Unsubscribe
	 * @param subscriptionId Subscription ID
	 */
	public function unsubscribe(subscriptionId:Int, onComplete:Dynamic->Void):Void
	{
		deleteRequest('$BASE_URL/Subscription/$subscriptionId', {}, onComplete);
	}

	// ============================================
	// SECTION 14: FILE ENDPOINTS
	// ============================================

	/**
	 * Get file contents
	 * @param fileId File ID
	 */
	public function getFileContents(fileId:Int, onComplete:Dynamic->Void):Void
	{
		loadRequest('$BASE_URL/File/$fileId', onComplete);
	}

	/**
	 * Download a file by ID (returns raw bytes)
	 * 
	 * Gets the file URL from Gamebanana's file API then downloads it.
	 * Use this when you have a Gamebanana file ID.
	 * 
	 * @param fileId The file's ID from Gamebanana
	 * @param onComplete Callback with the file bytes (can be saved or processed)
	 */
	public function downloadFile(fileId:Int, onComplete:#if HX_NX Bytes #else Bytes #end->Void):Void
	{
		getFileContents(fileId, function(data:Dynamic) {
			if (data != null && data._aFiles != null && data._aFiles.length > 0) {
				var fileUrl = data._aFiles[0]._sFileUrl;
				downloadFromUrl(fileUrl, onComplete);
			} else {
				if (onError != null)
					onError("No file found for ID: " + fileId);
			}
		});
	}

	/**
	 * Download file from direct URL (returns raw bytes)
	 * 
	 * Downloads any file from a direct URL. The data returned is raw bytes
	 * that you can save to disk or process however you need.
	 * 
	 * @param url Direct URL to the file (must be a direct download link)
	 * @param onComplete Callback with the file bytes
	 */
	public function downloadFromUrl(url:String, onComplete:#if HX_NX Bytes #else Bytes #end->Void):Void
	{
		#if HX_NX
		var http = new Http(url);
		http.onError = function(error:String)
		{
			if (onError != null)
				onError('Download Error: $error');
		};
		http.onBytes = function(bytes:#if HX_NX Bytes #else Bytes #end)
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
	 * 
	 * Downloads an image and converts it to a usable format.
	 * For OpenFL targets: returns BitmapData (can be used with FlxSprite)
	 * For HX_NX targets: returns VpTexture (can be used with VpSprite)
	 * 
	 * @param imageUrl URL of the image (jpg, png, gif, webp)
	 * @param onComplete Callback with the image as BitmapData or VpTexture
	 */
	public function downloadImage(imageUrl:String, onComplete:#if HX_NX VpTexture #else BitmapData #end->Void):Void
	{
		#if HX_NX
		downloadFromUrl(imageUrl, function(bytes:Bytes) {
			var texture = createTextureFromBytes(bytes);
			if (texture != null) {
				onComplete(texture);
			} else {
				if (onError != null)
					onError("Failed to create texture from image");
			}
		});
		#else
		downloadFromUrl(imageUrl, function(bytes:Bytes) {
			try {
				onComplete(BitmapData.fromBytes(bytes));
			} catch (e:Dynamic) {
				if (onError != null)
					onError('Error creating BitmapData: $e');
			}
		});
		#end
	}

	/**
	 * Get submission preview images and download them
	 * @param sectionSlug Section slug (Mod, Tool, etc.)
	 * @param submissionId Submission ID
	 * @param onComplete Callback with array of preview image URLs
	 */
	public function getSubmissionPreviewImages(sectionSlug:String, submissionId:Int, onComplete:Array<String>->Void):Void
	{
		getSubmissionProfilePage(sectionSlug, submissionId, function(data:Dynamic) {
			var previews:Array<String> = [];
			if (data != null && data._aPreviewMedia != null) {
				for (media in data._aPreviewMedia) {
					if (media._sBaseUrl != null && media._sFile != null) {
						previews.push(media._sBaseUrl + media._sFile);
					}
				}
			}
			onComplete(previews);
		});
	}

	/**
	 * Download first preview image of a submission
	 * 
	 * Gets the first preview/thumbnail image of a mod and downloads it.
	 * Useful for displaying mod thumbnails in your UI.
	 * 
	 * @param sectionSlug Section type (Mod, Tool, Game, etc.)
	 * @param submissionId The submission's ID
	 * @param onComplete Callback with the image as BitmapData or VpTexture
	 */
	public function downloadSubmissionPreview(sectionSlug:String, submissionId:Int, onComplete:#if HX_NX VpTexture #else BitmapData #end->Void):Void
	{
		getSubmissionPreviewImages(sectionSlug, submissionId, function(urls:Array<String>) {
			if (urls.length > 0) {
				downloadImage(urls[0], onComplete);
			} else {
				if (onError != null)
					onError("No preview images found");
			}
		});
	}

	/**
	 * Download all preview images of a submission
	 * 
	 * Gets ALL preview images from a submission and downloads them as an array.
	 * Returns BitmapData (OpenFL) or VpTexture (HX_NX) for each image.
	 * 
	 * @param sectionSlug Section type (Mod, Tool, Game, etc.)
	 * @param submissionId The submission's ID
	 * @param onComplete Callback with array of images
	 */
	public function downloadAllPreviews(sectionSlug:String, submissionId:Int, onComplete:Array<#if HX_NX VpTexture #else BitmapData #end>->Void):Void
	{
		getSubmissionPreviewImages(sectionSlug, submissionId, function(urls:Array<String>) {
			var images:Array<#if HX_NX VpTexture #else BitmapData #end> = [];
			
			if (urls.length == 0) {
				onComplete(images);
				return;
			}
			
			var completed = 0;
			for (url in urls) {
				downloadImage(url, function(img:#if HX_NX VpTexture #else BitmapData #end) {
					images.push(img);
					completed++;
					if (completed >= urls.length) {
						onComplete(images);
					}
				});
			}
		});
	}

	/**
	 * Download the first file from a submission
	 * 
	 * Gets the files list from a submission and downloads the first one.
	 * Use this for simple downloads where you just want the main file.
	 * 
	 * @param sectionSlug Section type (Mod, Tool, etc.)
	 * @param submissionId The submission's ID
	 * @param onComplete Callback with the file bytes
	 */
	public function downloadFirstFile(sectionSlug:String, submissionId:Int, onComplete:#if HX_NX Bytes #else Bytes #end->Void):Void
	{
		getSubmissionFiles(sectionSlug, submissionId, function(files:Dynamic) {
			if (files != null && files.length > 0) {
				var fileUrl = files[0]._sFileUrl;
				downloadFromUrl(fileUrl, onComplete);
			} else {
				if (onError != null)
					onError("No files found for submission");
			}
		});
	}

	/**
	 * Get ZIP file tree structure
	 * 
	 * Gets the internal file structure of a ZIP file without downloading it.
	 * Returns a tree showing all files and folders inside the archive.
	 * 
	 * @param fileId The file's ID from Gamebanana
	 * @param onComplete Callback with the ZIP tree structure
	 */
	public function getZipTree(fileId:Int, onComplete:Dynamic->Void):Void
	{
		loadRequest('$BASE_URL/File/$fileId', onComplete);
	}

	/**
	 * Download ZIP file by ID
	 * 
	 * Downloads the entire ZIP file from Gamebanana.
	 * Returns raw bytes - you can save this as a .zip file on disk.
	 * 
	 * @param fileId The file's ID from Gamebanana
	 * @param onComplete Callback with the ZIP file bytes
	 */
	public function downloadZipFile(fileId:Int, onComplete:#if HX_NX Bytes #else Bytes #end->Void):Void
	{
		downloadFile(fileId, onComplete);
	}

	/**
	 * Download file with progress tracking (placeholder)
	 * 
	 * Note: Full progress tracking would require implementing with 
	 * openfl.events.ProgressEvent or cpp typed functions.
	 * For now, use downloadFile or downloadFromUrl.
	 * 
	 * @param fileId File ID
	 * @param onComplete Callback with bytes
	 * @param onProgress Progress callback (not implemented)
	 */
	public function downloadFileWithProgress(fileId:Int, onComplete:#if HX_NX Bytes #else Bytes #end->Void, ?onProgress:Float->Void):Void
	{
		downloadFile(fileId, onComplete);
	}

	// ============================================
	// SECTION 15: MEMBER PROFILE ENDPOINTS
	// ============================================

	/**
	 * Get member profile page
	 * @param memberId Member ID
	 */
	public function getMemberProfilePage(memberId:Int, onComplete:Dynamic->Void):Void
	{
		loadRequest('$BASE_URL/Member/$memberId/ProfilePage', onComplete);
	}

	/**
	 * Get moderators list
	 */
	public function getModerators(onComplete:Dynamic->Void):Void
	{
		loadRequest('$BASE_URL/Member/Moderators', onComplete);
	}

	/**
	 * Get game managers list
	 */
	public function getGameManagers(onComplete:Dynamic->Void):Void
	{
		loadRequest('$BASE_URL/Member/GameManagers', onComplete);
	}

	/**
	 * Get currently online members
	 */
	public function getOnlineMembers(onComplete:Dynamic->Void):Void
	{
		loadRequest('$BASE_URL/Member/Online', onComplete);
	}

	// ============================================
	// SECTION 16: GENERIC DISCUSSION ENDPOINTS
	// ============================================

	/**
	 * Get recent discussions (global)
	 */
	public function getRecentDiscussions(onComplete:Dynamic->Void):Void
	{
		loadRequest('$BASE_URL/Util/Generic/Discussions', onComplete);
	}

	// ============================================
	// PRIVATE HELPER METHODS
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
					onError("Failed to create SDL_RWops from bytes data");
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

	private function loadImageBytesHXNX(url:String, onComplete:Bytes->Void):Void
	{
		var http = new Http(url);
		http.onError = function(error:String)
		{
			if (onError != null)
				onError('HTTP Error: $error');
		};
		http.onBytes = function(bytes:Bytes)
		{
			try
			{
				onComplete(bytes);
			}
			catch (e:Dynamic)
			{
				if (onError != null)
					onError('Error processing bytes: $e');
			}
		};
		http.request(false);
	}
	#end

	private function loadRequest(url:String, onComplete:Dynamic->Void #if !HX_NX, ?format:URLLoaderDataFormat #end)
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
		loader.dataFormat = format ?? URLLoaderDataFormat.TEXT;
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

	private function postRequest(url:String, data:Map<String, Dynamic>, onComplete:Dynamic->Void):Void
	{
		#if HX_NX
		var http = new Http(url);
		http.setPostData encodeParams(data);
		http.onError = function(error:String)
		{
			if (onError != null)
				onError('HTTP Error: $error');
		};
		http.onData = function(response:String)
		{
			try
			{
				onComplete(Json.parse(response));
			}
			catch (e:Dynamic)
			{
				if (onError != null)
					onError(e);
			}
		};
		http.request(true);
		#else
		var loader:URLLoader = new URLLoader();
		loader.dataFormat = URLLoaderDataFormat.TEXT;
		var request = new URLRequest(url);
		request.method = "POST";
		request.data = encodeParamsFormData(data);
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
		loader.load(request);
		#end
	}

	private function deleteRequest(url:String, data:Map<String, Dynamic>, onComplete:Dynamic->Void):Void
	{
		#if HX_NX
		var http = new Http(url);
		http.setPostData encodeParams(data);
		http.onError = function(error:String)
		{
			if (onError != null)
				onError('HTTP Error: $error');
		};
		http.onData = function(response:String)
		{
			try
			{
				onComplete(Json.parse(response));
			}
			catch (e:Dynamic)
			{
				if (onError != null)
					onError(e);
			}
		};
		http.request(true);
		#else
		var loader:URLLoader = new URLLoader();
		loader.dataFormat = URLLoaderDataFormat.TEXT;
		var request = new URLRequest(url);
		request.method = "DELETE";
		request.data = encodeParamsFormData(data);
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
		loader.load(request);
		#end
	}

	private function patchRequest(url:String, data:Map<String, Dynamic>, onComplete:Dynamic->Void):Void
	{
		#if HX_NX
		var http = new Http(url);
		http.setPostData encodeParams(data);
		http.onError = function(error:String)
		{
			if (onError != null)
				onError('HTTP Error: $error');
		};
		http.onData = function(response:String)
		{
			try
			{
				onComplete(Json.parse(response));
			}
			catch (e:Dynamic)
			{
				if (onError != null)
					onError(e);
			}
		};
		http.request(true);
		#else
		var loader:URLLoader = new URLLoader();
		loader.dataFormat = URLLoaderDataFormat.TEXT;
		var request = new URLRequest(url);
		request.method = "PATCH";
		request.data = encodeParamsFormData(data);
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
		loader.load(request);
		#end
	}

	private function encodeParams(data:Map<String, Dynamic>):String
	{
		var parts:Array<String> = [];
		for (key in data.keys()) {
			parts.push(key + '=' + urlEncode(Std.string(data.get(key))));
		}
		return parts.join('&');
	}

	#if !HX_NX
	private function encodeParamsFormData(data:Map<String, Dynamic>):String
	{
		var parts:Array<String> = [];
		for (key in data.keys()) {
			parts.push(key + '=' + urlEncode(Std.string(data.get(key))));
		}
		return parts.join('&');
	}
	#end
}
