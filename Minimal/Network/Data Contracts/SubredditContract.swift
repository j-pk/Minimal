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
                submit_text_html: "&lt;!-- SC_OFF --&gt;&lt;div class="
                md "&gt;&lt;p&gt;&lt;strong&gt;AskReddit is all about DISCUSSION. Your post needs to inspire discussion, ask an open-ended question that prompts redditors to share ideas or opinions.&lt;/strong&gt;&lt;/p&gt; &lt;p&gt;&lt;strong&gt;Questions need to be neutral and the question alone.&lt;/strong&gt; Any opinion or answer must go as a reply to your question, this includes examples or any kind of story about you. This is so that all responses will be to your question, and there&amp;#39;s nothing else to respond to. Opinionated posts are forbidden.&lt;/p&gt; &lt;ul&gt; &lt;li&gt;If your question has a factual answer, try &lt;a href=" / r / answers "&gt;/r/answers&lt;/a&gt;.&lt;/li&gt; &lt;li&gt;If you are trying to find out about something or get an explanation, try &lt;a href=" / r / explainlikeimfive "&gt;/r/explainlikeimfive&lt;/a&gt;&lt;/li&gt; &lt;li&gt;If your question has a limited number of responses, then it&amp;#39;s not suitable.&lt;/li&gt; &lt;li&gt;If you&amp;#39;re asking for any kind of advice, then it&amp;#39;s not suitable.&lt;/li&gt; &lt;li&gt;If you feel the need to add an example in order for your question to make sense then you need to re-word your question.&lt;/li&gt; &lt;li&gt;If you&amp;#39;re explaining why you&amp;#39;re asking the question, you need to stop.&lt;/li&gt; &lt;/ul&gt; &lt;p&gt;You can always ask where best to post in &lt;a href=" / r / findareddit "&gt;/r/findareddit&lt;/a&gt;.&lt;/p&gt; &lt;/div&gt;&lt;!-- SC_ON --&gt;",
                user_is_banned: null,
                wiki_enabled: true,
                show_media: false,
                id: "2qh1i",
                display_name_prefixed: "r/AskReddit",
                submit_text: "**AskReddit is all about DISCUSSION. Your post needs to inspire discussion, ask an open-ended question that prompts redditors to share ideas or opinions.** **Questions need to be neutral and the question alone.** Any opinion or answer must go as a reply to your question, this includes examples or any kind of story about you. This is so that all responses will be to your question, and there's nothing else to respond to. Opinionated posts are forbidden. * If your question has a factual answer, try /r/answers. * If you are trying to find out about something or get an explanation, try /r/explainlikeimfive * If your question has a limited number of responses, then it's not suitable. * If you're asking for any kind of advice, then it's not suitable. * If you feel the need to add an example in order for your question to make sense then you need to re-word your question. * If you're explaining why you're asking the question, you need to stop. You can always ask where best to post in /r/findareddit.",
                user_can_flair_in_sr: null,
                display_name: "AskReddit",
                header_img: "https://a.thumbs.redditmedia.com/IrfPJGuWzi_ewrDTBlnULeZsJYGz81hsSQoQJyw6LD8.png",
                description_html: "&lt;!-- SC_OFF --&gt;&lt;div class="
                md "&gt;&lt;h6&gt;&lt;a href="
                http: //www.reddit.com/r/askreddit/submit?selftext=true&amp;amp;title=%5BSerious%5D"&gt; [ SERIOUS ] &lt;/a&gt;&lt;/h6&gt; &lt;h5&gt;&lt;a href="https://www.reddit.com/r/AskReddit/wiki/index#wiki_rules"&gt;Rules&lt;/a&gt;:&lt;/h5&gt; &lt;ol&gt; &lt;li&gt;&lt;p&gt;You must post a clear and direct question in the title. The title may contain two, short, necessary context sentences. No text is allowed in the textbox. Your thoughts/responses to the question can go in the comments section. &lt;a href="http://goo.gl/tMUR4k"&gt;more &amp;gt;&amp;gt;&lt;/a&gt;&lt;/p&gt;&lt;/li&gt; &lt;li&gt;&lt;p&gt;Any post asking for advice should be generic and not specific to your situation alone. &lt;a href="http://goo.gl/2L771B"&gt;more &amp;gt;&amp;gt;&lt;/a&gt;&lt;/p&gt;&lt;/li&gt; &lt;li&gt;&lt;p&gt;Askreddit is for open-ended discussion questions. &lt;a href="http://goo.gl/DcPPLf"&gt;more &amp;gt;&amp;gt;&lt;/a&gt;&lt;/p&gt;&lt;/li&gt; &lt;li&gt;&lt;p&gt;Posting, or seeking, any identifying personal information, real or fake, will result in a ban without a prior warning. &lt;a href="http://goo.gl/imCCMb"&gt;more &amp;gt;&amp;gt;&lt;/a&gt;&lt;/p&gt;&lt;/li&gt; &lt;li&gt;&lt;p&gt;Askreddit is not your soapbox, personal army, or advertising platform. &lt;a href="http://goo.gl/DG4Q2M"&gt;more &amp;gt;&amp;gt;&lt;/a&gt;&lt;/p&gt;&lt;/li&gt; &lt;li&gt;&lt;p&gt;Questions seeking professional advice are inappropriate for this subreddit and will be removed. &lt;a href="http://goo.gl/G6Zbap"&gt;more &amp;gt;&amp;gt;&lt;/a&gt;&lt;/p&gt;&lt;/li&gt; &lt;li&gt;&lt;p&gt;Soliciting money, goods, services, or favours is not allowed. &lt;a href="http://goo.gl/Ce2LTY"&gt;more &amp;gt;&amp;gt;&lt;/a&gt;&lt;/p&gt;&lt;/li&gt; &lt;li&gt;&lt;p&gt;Mods reserve the right to remove content or restrict users&amp;#39; posting privileges as necessary if it is deemed detrimental to the subreddit or to the experience of others. &lt;a href="http://goo.gl/a5GQTm"&gt;more &amp;gt;&amp;gt;&lt;/a&gt;&lt;/p&gt;&lt;/li&gt; &lt;li&gt;&lt;p&gt;Comment replies consisting solely of images will be removed. &lt;a href="http://goo.gl/YVNgU0"&gt;more &amp;gt;&amp;gt;&lt;/a&gt;&lt;/p&gt;&lt;/li&gt; &lt;/ol&gt; &lt;h5&gt;If you think your post has disappeared, see spam or an inappropriate post, please do not hesitate to &lt;a href="http://goo.gl/xnppZr"&gt;contact the mods&lt;/a&gt;, we&amp;#39;re happy to help.&lt;/h5&gt; &lt;hr/&gt; &lt;h4&gt;Tags to use:&lt;/h4&gt; &lt;blockquote&gt; &lt;h2&gt;&lt;a href="http://goo.gl/gMFZjB"&gt;[Serious]&lt;/a&gt;&lt;/h2&gt; &lt;/blockquote&gt; &lt;h3&gt;Use a &lt;strong&gt;[Serious]&lt;/strong&gt; post tag to designate your post as a serious, on-topic-only thread.&lt;/h3&gt; &lt;h2&gt;&lt;/h2&gt; &lt;h4&gt;Filter posts by subject:&lt;/h4&gt; &lt;p&gt;&lt;a href="http://ud.reddit.com/r/AskReddit/#ud"&gt;Mod posts&lt;/a&gt; &lt;a href="http://dg.reddit.com/r/AskReddit/#dg"&gt;Serious posts&lt;/a&gt; &lt;a href="http://bu.reddit.com/r/AskReddit/#bu"&gt;Megathread&lt;/a&gt; &lt;a href="http://nr.reddit.com/r/AskReddit/#nr"&gt;Breaking news&lt;/a&gt; &lt;a href="http://goo.gl/qJBQRm"&gt;Unfilter&lt;/a&gt;&lt;/p&gt; &lt;h2&gt;&lt;/h2&gt; &lt;h3&gt;Do you have ideas or feedback for Askreddit? Submit to &lt;a href="http://www.reddit.com/r/Ideasforaskreddit"&gt;/r/Ideasforaskreddit&lt;/a&gt;.&lt;/h3&gt; &lt;h2&gt;&lt;/h2&gt; &lt;h3&gt;We have spoiler tags, please use them! /spoiler, #spoiler, /s, #s. Use it &lt;code&gt;[like this](/spoiler)&lt;/code&gt;&lt;/h3&gt; &lt;h2&gt;&lt;/h2&gt; &lt;h4&gt;Other subreddits you might like:&lt;/h4&gt; &lt;table&gt;&lt;thead&gt; &lt;tr&gt; &lt;th align="left"&gt;some&lt;/th&gt; &lt;th align="left"&gt;header&lt;/th&gt; &lt;/tr&gt; &lt;/thead&gt;&lt;tbody&gt; &lt;tr&gt; &lt;td align="left"&gt;&lt;a href="https://www.reddit.com/r/AskReddit/wiki/sidebarsubs#wiki_ask_others"&gt;Ask Others&lt;/a&gt;&lt;/td&gt; &lt;td align="left"&gt;&lt;a href="https://www.reddit.com/r/AskReddit/wiki/sidebarsubs#wiki_self_.26amp.3B_others"&gt;Self &amp;amp; Others&lt;/a&gt;&lt;/td&gt; &lt;/tr&gt; &lt;tr&gt; &lt;td align="left"&gt;&lt;a href="https://www.reddit.com/r/AskReddit/wiki/sidebarsubs#wiki_find_a_subreddit"&gt;Find a subreddit&lt;/a&gt;&lt;/td&gt; &lt;td align="left"&gt;&lt;a href="https://www.reddit.com/r/AskReddit/wiki/sidebarsubs#wiki_learn_something"&gt;Learn something&lt;/a&gt;&lt;/td&gt; &lt;/tr&gt; &lt;tr&gt; &lt;td align="left"&gt;&lt;a href="https://www.reddit.com/r/AskReddit/wiki/sidebarsubs#wiki_meta"&gt;Meta Subs&lt;/a&gt;&lt;/td&gt; &lt;td align="left"&gt;&lt;a href="https://www.reddit.com/r/AskReddit/wiki/sidebarsubs#wiki_what_is_this______"&gt;What is this ___&lt;/a&gt;&lt;/td&gt; &lt;/tr&gt; &lt;tr&gt; &lt;td align="left"&gt;&lt;a href="https://www.reddit.com/r/AskReddit/wiki/sidebarsubs#wiki_askreddit_offshoots"&gt;AskReddit Offshoots&lt;/a&gt;&lt;/td&gt; &lt;td align="left"&gt;&lt;a href="https://www.reddit.com/r/AskReddit/wiki/sidebarsubs#wiki_offers_.26amp.3B_assistance"&gt;Offers &amp;amp; Assistance&lt;/a&gt;&lt;/td&gt; &lt;/tr&gt; &lt;/tbody&gt;&lt;/table&gt; &lt;h2&gt;&lt;/h2&gt; &lt;h3&gt;Ever read the reddiquette? &lt;a href="http://goo.gl/pxsd8T"&gt;Take a peek!&lt;/a&gt;&lt;/h3&gt; &lt;p&gt;&lt;a href="#/RES_SR_Config/NightModeCompatible"&gt;&lt;/a&gt; &lt;a href="http://goo.gl/TQnRmU"&gt;&lt;/a&gt; &lt;a href="#may4th"&gt;&lt;/a&gt;&lt;/p&gt; &lt;/div&gt;&lt;!-- SC_ON --&gt;",
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
                description: "###### [ [ SERIOUS ] ](http://www.reddit.com/r/askreddit/submit?selftext=true&amp;title=%5BSerious%5D) ##### [Rules](https://www.reddit.com/r/AskReddit/wiki/index#wiki_rules): 1. You must post a clear and direct question in the title. The title may contain two, short, necessary context sentences. No text is allowed in the textbox. Your thoughts/responses to the question can go in the comments section. [more &gt;&gt;](http://goo.gl/tMUR4k) 2. Any post asking for advice should be generic and not specific to your situation alone. [more &gt;&gt;](http://goo.gl/2L771B) 3. Askreddit is for open-ended discussion questions. [more &gt;&gt;](http://goo.gl/DcPPLf) 4. Posting, or seeking, any identifying personal information, real or fake, will result in a ban without a prior warning. [more &gt;&gt;](http://goo.gl/imCCMb) 5. Askreddit is not your soapbox, personal army, or advertising platform. [more &gt;&gt;](http://goo.gl/DG4Q2M) 6. Questions seeking professional advice are inappropriate for this subreddit and will be removed. [more &gt;&gt;](http://goo.gl/G6Zbap) 7. Soliciting money, goods, services, or favours is not allowed. [more &gt;&gt;](http://goo.gl/Ce2LTY) 8. Mods reserve the right to remove content or restrict users' posting privileges as necessary if it is deemed detrimental to the subreddit or to the experience of others. [more &gt;&gt;](http://goo.gl/a5GQTm) 9. Comment replies consisting solely of images will be removed. [more &gt;&gt;](http://goo.gl/YVNgU0) ##### If you think your post has disappeared, see spam or an inappropriate post, please do not hesitate to [contact the mods](http://goo.gl/xnppZr), we're happy to help. --- #### Tags to use: &gt; ## [[Serious]](http://goo.gl/gMFZjB) ### Use a **[Serious]** post tag to designate your post as a serious, on-topic-only thread. - #### Filter posts by subject: [Mod posts](http://ud.reddit.com/r/AskReddit/#ud) [Serious posts](http://dg.reddit.com/r/AskReddit/#dg) [Megathread](http://bu.reddit.com/r/AskReddit/#bu) [Breaking news](http://nr.reddit.com/r/AskReddit/#nr) [Unfilter](http://goo.gl/qJBQRm) - ### Do you have ideas or feedback for Askreddit? Submit to [/r/Ideasforaskreddit](http://www.reddit.com/r/Ideasforaskreddit). - ### We have spoiler tags, please use them! /spoiler, #spoiler, /s, #s. Use it `[like this](/spoiler)` - #### Other subreddits you might like: some|header :---|:--- [Ask Others](https://www.reddit.com/r/AskReddit/wiki/sidebarsubs#wiki_ask_others)|[Self &amp; Others](https://www.reddit.com/r/AskReddit/wiki/sidebarsubs#wiki_self_.26amp.3B_others) [Find a subreddit](https://www.reddit.com/r/AskReddit/wiki/sidebarsubs#wiki_find_a_subreddit)|[Learn something](https://www.reddit.com/r/AskReddit/wiki/sidebarsubs#wiki_learn_something) [Meta Subs](https://www.reddit.com/r/AskReddit/wiki/sidebarsubs#wiki_meta)|[What is this ___](https://www.reddit.com/r/AskReddit/wiki/sidebarsubs#wiki_what_is_this______) [AskReddit Offshoots](https://www.reddit.com/r/AskReddit/wiki/sidebarsubs#wiki_askreddit_offshoots)|[Offers &amp; Assistance](https://www.reddit.com/r/AskReddit/wiki/sidebarsubs#wiki_offers_.26amp.3B_assistance) - ### Ever read the reddiquette? [Take a peek!](http://goo.gl/pxsd8T) [](#/RES_SR_Config/NightModeCompatible) [](http://goo.gl/TQnRmU) [](#may4th) ",
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

struct SubredditObject: Mappable {
    let id: String?
    let displayNamePrefixed: String?
    let displayName: String?
    let over18: Bool
    let iconImage: String?
    let subscribers: Int
    let publicDescription: String?
    let allowImages: Bool
    let allowVideoGifs: Bool
    let isSubscribed: Bool?
    
    enum CodingKeys: String, CodingKey {
        case data
        case id
        case displayNamePrefixed = "display_name_prefixed"
        case displayName = "display_name"
        case iconImage = "icon_img"
        case publicDescription = "public_description"
        case allowImages = "allow_images"
        case allowVideoGifs = "allow_videogifs"
        case isSubscribed = "user_is_subscriber"
        case over18
        case subscribers
    }
    
    init(from decoder: Decoder) throws {
        let root = try decoder.container(keyedBy: CodingKeys.self)
        let data = try root.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
        id = try data.decodeIfPresent(String.self, forKey: .id)
        displayNamePrefixed = try data.decodeIfPresent(String.self, forKey: .displayNamePrefixed)
        displayName = try data.decodeIfPresent(String.self, forKey: .displayName)
        over18 = try data.decode(Bool.self, forKey: .over18)
        iconImage = try data.decodeIfPresent(String.self, forKey: .iconImage)
        subscribers = try data.decode(Int.self, forKey: .subscribers)
        publicDescription = try data.decodeIfPresent(String.self, forKey: .publicDescription)
        allowImages = try data.decode(Bool.self, forKey: .allowImages)
        allowVideoGifs = try data.decode(Bool.self, forKey: .allowVideoGifs)
        isSubscribed = try data.decodeIfPresent(Bool.self, forKey: .isSubscribed)
    }
}

