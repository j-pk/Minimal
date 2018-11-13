//
//  SubredditContract.swift
//  Minimal
//
//  Created by Jameson Kirby on 1/22/18.
//  Copyright © 2018 Parker Kirby. All rights reserved.
//

import Foundation
/*
{
    kind: "Listing",
    data: {
        after: "t5_2qh16",
        dist: 25,
        modhash: "",
        whitelist_status: "all_ads",
        children: [{
            kind: "t5",
            data: {
                hide_ads: false,
                banner_img: "https://b.thumbs.redditmedia.com/PXt8GnqdYu-9lgzb3iesJBLN21bXExRV1A45zdw4sYE.png",
                user_sr_theme_enabled: true,
                user_has_favorited: null,
                submit_text_html: "",
                user_is_banned: null,
                wiki_enabled: true,
                show_media: false,
                id: "2qh1i",
                display_name_prefixed: "r/AskReddit",
                submit_text: "",
                user_can_flair_in_sr: null,
                display_name: "AskReddit",
                header_img: "https://a.thumbs.redditmedia.com/IrfPJGuWzi_ewrDTBlnULeZsJYGz81hsSQoQJyw6LD8.png",
                description_html: "",
                title: "Ask Reddit...",
                collapse_deleted_comments: true,
                user_flair_text: null,
                over18: false,
                public_description_html: "&lt;!-- SC_OFF --&gt;&lt;div class="
                md "&gt;&lt;p&gt;&lt;a href=" / r / AskReddit "&gt;/r/AskReddit&lt;/a&gt; is the place to ask and answer thought-provoking questions.&lt;/p&gt; &lt;/div&gt;&lt;!-- SC_ON --&gt;",
                allow_videos: false,
                spoilers_enabled: true,
                icon_size: [
                    256,
                    256
                ],
                audience_target: "stories",
                suggested_comment_sort: null,
                active_user_count: null,
                icon_img: "https://b.thumbs.redditmedia.com/EndDxMGB-FTZ2MGtjepQ06cQEkZw_YQAsOUudpb9nSQ.png",
                header_title: "Ass Credit",
                description: "",
                user_is_muted: null,
                submit_link_label: null,
                accounts_active: null,
                public_traffic: false,
                header_size: [
                125,
                73
                ],
                subscribers: 18566900,
                user_flair_css_class: null,
                submit_text_label: "Ask a question",
                whitelist_status: "all_ads",
                user_sr_flair_enabled: null,
                lang: "es",
                user_is_moderator: null,
                is_enrolled_in_new_modmail: null,
                key_color: "#222222",
                name: "t5_2qh1i",
                user_flair_enabled_in_sr: false,
                allow_videogifs: false,
                url: "/r/AskReddit/",
                quarantine: false,
                created: 1201261935,
                created_utc: 1201233135,
                banner_size: [
                1280,
                384
                ],
                user_is_contributor: null,
                allow_discovery: true,
                accounts_active_is_fuzzed: false,
                advertiser_category: "Lifestyles",
                public_description: "/r/AskReddit is the place to ask and answer thought-provoking questions.",
                link_flair_enabled: true,
                allow_images: true,
                show_media_preview: true,
                comment_score_hide_mins: 60,
                subreddit_type: "public",
                submission_type: "self",
                user_is_subscriber: null
                }
            }
        }]
    before: null
}
*/

struct SubredditStore: Decodable {
    let before: String?
    let after: String?
    let subreddits: [SubredditObject]
    
    enum CodingKeys: String, CodingKey {
        case data
    }
    
    enum ChildrenCodingKeys: String, CodingKey {
        case subreddits = "children"
        case before
        case after
    }
    
    init(from decoder: Decoder) throws {
        let root = try decoder.container(keyedBy: CodingKeys.self)
        let data = try root.nestedContainer(keyedBy: ChildrenCodingKeys.self, forKey: .data)
        before = try data.decodeIfPresent(String.self, forKey: .before)
        after = try data.decodeIfPresent(String.self, forKey: .after)
        subreddits = try data.decode([SubredditObject].self, forKey: .subreddits)
    }
}

struct SubredditObject: Decodable {
    let id: String
    let displayNamePrefixed: String?
    let displayName: String?
    let over18: Bool
    let iconImage: String?
    let subscribers: Int
    let publicDescription: String?
    let allowImages: Bool?
    let allowVideoGifs: Bool?
    let isSubscribed: Bool?
    
    enum CodingKeys: String, CodingKey {
        case data
        case id
        case displayNamePrefixed = "display_name_prefixed"
        case subredditNamePrefixed = "subreddit_name_prefixed"
        case displayName = "display_name"
        case subreddit
        case iconImage = "icon_img"
        case publicDescription = "public_description"
        case selftext
        case allowImages = "allow_images"
        case allowVideoGifs = "allow_videogifs"
        case isSubscribed = "user_is_subscriber"
        case over18 = "over_18"
        case subscribers = "subreddit_subscribers"
    }
    
    init(from decoder: Decoder) throws {
        let root = try decoder.container(keyedBy: CodingKeys.self)
        let data = try root.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
        id = try data.decode(String.self, forKey: .id)
        displayNamePrefixed = try data.decodeIfPresent(String.self, forKey: .displayNamePrefixed) ?? data.decodeIfPresent(String.self, forKey: .subredditNamePrefixed)
        displayName = try data.decodeIfPresent(String.self, forKey: .displayName) ?? data.decodeIfPresent(String.self, forKey: .subreddit)
        over18 = try data.decode(Bool.self, forKey: .over18)
        iconImage = try data.decodeIfPresent(String.self, forKey: .iconImage)
        subscribers = try data.decode(Int.self, forKey: .subscribers)
        publicDescription = try data.decodeIfPresent(String.self, forKey: .publicDescription) ?? data.decodeIfPresent(String.self, forKey: .selftext)
        allowImages = try data.decodeIfPresent(Bool.self, forKey: .allowImages)
        allowVideoGifs = try data.decodeIfPresent(Bool.self, forKey: .allowVideoGifs)
        isSubscribed = try data.decodeIfPresent(Bool.self, forKey: .isSubscribed)
    }
}

