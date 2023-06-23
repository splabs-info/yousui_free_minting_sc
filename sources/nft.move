module yousuinfts::nft {
    use sui::url::{Self, Url};
    use std::string::{utf8, String};
    use sui::object::{Self, ID, UID};
    use sui::event;
    use sui::transfer;
    use sui::tx_context::{Self,sender, TxContext};
    use sui::package;
    use sui::display;

    friend yousuinfts::freemint; 
    friend yousuinfts::freemintv2; 

    const ENotAuthorized: u64 = 1; 

    struct YOUSUINFT has key, store {
        id: UID,
        name: String,
        description: String,
        type: vector<u8>,
        image_url: Url,
        project_url: Url,
    }

    struct NFTMinted has copy, drop {
        object_id: ID,
        creator: address,
        name: String,
    }

    struct Infomation has key {
        id: UID,
        name: String,
        mint_index: u64,
        project_url: Url,
        description_og: String,
        description_pfp: String,
        description_tier1: String,
        description_tier2: String,
        description_tier3: String,
        description_tier4: String,
        description_tier5: String,
        creator: address,
    }

    /// One-Time-Witness for the module.
    struct NFT has drop {}


    fun init(witness: NFT,ctx: &mut TxContext) {
        let init_info = Infomation {
            id: object::new(ctx),
            name: utf8(b"YOUSUI NFT"),
            mint_index: 20230001,
            project_url:   url::new_unsafe_from_bytes(b"https://yousui.io/"),
            description_og: utf8(b"OG NFTs can be issued with a very low probability. OG NFTs are NFTs that will have the right to participate in the IDO Launchpad of XUI Tokens. Be sure to hold it until the end of the IDO Launchpad. Confirmed XUI Allocation will be of great benefit to you."),
            description_pfp: utf8(b"Decorate your profile with pretty characters! Don't you know? Moderators passing by can see your pretty profile and give you XP points!"),
            description_tier1: utf8(b""),
            description_tier2: utf8(b""),
            description_tier3: utf8(b""),
            description_tier4: utf8(b""),
            description_tier5: utf8(b"Users generally need to stake 3000 XUI tokens to use IDO Launchpad or INO Launchpad. If you hold Tier 5 NFTs, you can participate in IDO Launchpad and INO Launchpad without needing to stake 3000 XUI."),
            creator: tx_context::sender(ctx),
        };

         let keys = vector[
            utf8(b"name"),
            utf8(b"image_url"),
            utf8(b"description"),
            utf8(b"project_url"),
        ];

        let values = vector[
            utf8(b"{name}"),
            utf8(b"{image_url}"),
            utf8(b"{description}"),
            utf8(b"{project_url}"),
        ];

     
        let publisher = package::claim(witness, ctx);
        let display = display::new_with_fields<YOUSUINFT>(
            &publisher, keys, values, ctx
        );

        // Commit first version of `Display` to apply changes.
        display::update_version(&mut display);
       
        transfer::public_transfer(publisher, sender(ctx));
        transfer::public_transfer(display, sender(ctx));
        transfer::share_object(init_info);
       
    }

    
    public fun name(nft: &YOUSUINFT): &String {
        &nft.name
    }

    public fun description(nft: &YOUSUINFT): &String {
        &nft.description
    }

    public fun image_url(nft: &YOUSUINFT): &Url {
        &nft.image_url
    }

    public fun project_url(nft: &YOUSUINFT): &Url {
        &nft.project_url
    }

    public fun type(nft: &YOUSUINFT): vector<u8>{
        nft.type
    }
  
    public(friend) fun mint( type: vector<u8>, image_url:  vector<u8>,info: &mut Infomation,
        ctx: &mut TxContext
    ) {
        let sender = tx_context::sender(ctx);

        let description: String;
        description = utf8(b"");

        if(type == b"og"){
            description = info.description_og;
        };

        if(type == b"pfp"){
            description = info.description_pfp;
        };
        if(type == b"1") {
            description = info.description_tier1;
        };
        if(type == b"2") {
            description = info.description_tier2;
        };

        if(type == b"3") {
            description = info.description_tier3;
        };

        if(type == b"4") {
            description = info.description_tier4;
        };

        if(type == b"5") {
            description = info.description_tier5;
        };
        
        let nft = YOUSUINFT {
            id: object::new(ctx),
            name: utf8(b"YOUSUI"),
            description: description,
            type: type,
            project_url: info.project_url,
            image_url:  url::new_unsafe_from_bytes(image_url),
         
        };
      
        event::emit(NFTMinted {
            object_id: object::id(&nft),
            creator: sender,
            name: nft.name,
        });

        info.mint_index = info.mint_index +1;
        transfer::public_transfer(nft, sender);
    }


    public entry fun transfer(
        nft: YOUSUINFT, recipient: address, _: &mut TxContext
    ) {
        transfer::public_transfer(nft, recipient)
    }

    public entry fun update_description_og(
        info: &mut Infomation,
        new_description: String,
        ctx: &mut TxContext
    ) {
        assert!(info.creator == tx_context::sender(ctx), ENotAuthorized);
        info.description_og = new_description
    }

    public entry fun update_description_pfp(
        info: &mut Infomation,
        new_description: String,
        ctx: &mut TxContext
    ) {
        assert!(info.creator == tx_context::sender(ctx), ENotAuthorized);
        info.description_pfp = new_description
    }


    public entry fun update_description_tier1(
        info: &mut Infomation,
        new_description: String,
        ctx: &mut TxContext
    ) {
        assert!(info.creator == tx_context::sender(ctx), ENotAuthorized);
        info.description_tier1 = new_description
    }

    public entry fun update_description_tier2(
        info: &mut Infomation,
        new_description: String,
        ctx: &mut TxContext
    ) {
        assert!(info.creator == tx_context::sender(ctx), ENotAuthorized);
        info.description_tier2 = new_description
    }

    public entry fun update_description_tier3(
        info: &mut Infomation,
        new_description: String,
        ctx: &mut TxContext
    ) {
        assert!(info.creator == tx_context::sender(ctx), ENotAuthorized);
        info.description_tier3 = new_description
    }

    public entry fun update_description_tier4(
        info: &mut Infomation,
        new_description: String,
        ctx: &mut TxContext
    ) {
        assert!(info.creator == tx_context::sender(ctx), ENotAuthorized);
        info.description_tier4 = new_description
    }

    public entry fun update_description_tier5(
        info: &mut Infomation,
        new_description: String,
        ctx: &mut TxContext
    ) {
        assert!(info.creator == tx_context::sender(ctx), ENotAuthorized);
        info.description_tier5 = new_description
    }

    public entry fun burn(nft: YOUSUINFT, _: &mut TxContext) {
        let YOUSUINFT { id, name: _, description: _, image_url: _ , type: _, project_url: _} = nft;
        object::delete(id)
    }
}