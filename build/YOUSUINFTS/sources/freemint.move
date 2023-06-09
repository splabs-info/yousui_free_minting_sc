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

    public fun get_type(nft: &YOUSUINFT):&vector<u8>{
        &nft.type
    }
  
    public(friend) fun mint( type: vector<u8>, info: &mut Infomation,
        ctx: &mut TxContext
    ) {
        let sender = tx_context::sender(ctx);

        let url_image: vector<u8>;
        let description: String;

        url_image = b"";
        description = utf8(b"");

        if(type == b"og"){
            url_image = b"https://files.yousui.io/mint/YouSUI_NFT_OGROLE.png";
            description = info.description_og;
        };

        if(type == b"pfp"){
            description = info.description_pfp;
            if(info.mint_index %4 == 0)
            url_image = b"https://files.yousui.io/mint/YouSUI_NFT_PFP4.png";
            if(info.mint_index %4 == 1)
            url_image = b"https://files.yousui.io/mint/YouSUI_NFT_PFP1.png";
            if(info.mint_index %4 == 2)
            url_image = b"https://files.yousui.io/mint/YouSUI_NFT_PFP2.png";
            if(info.mint_index %4 == 3)
            url_image = b"https://files.yousui.io/mint/YouSUI_NFT_PFP3.png";

        };
        if(type == b"1") {
            description = info.description_tier1;
            url_image = b"https://files.yousui.io/mint/YouSUI_NFT_TIER1.png";
        };
        if(type == b"2") {
            description = info.description_tier2;
            url_image = b"https://files.yousui.io/mint/YouSUI_NFT_TIER2.png";
        };

        if(type == b"3") {
            description = info.description_tier3;
            url_image = b"https://files.yousui.io/mint/YouSUI_NFT_TIER3.png";
        };

        if(type == b"4") {
            description = info.description_tier4;
            url_image = b"https://files.yousui.io/mint/YouSUI_NFT_TIER4.png";
        };

        if(type == b"5") {
            description = info.description_tier5;
            url_image = b"https://files.yousui.io/mint/YouSUI_NFT_TIER5.png";
        };
        
        let nft = YOUSUINFT {
            id: object::new(ctx),
            name: utf8(b"YOUSUI"),
            description: description,
            type: type,
            project_url: info.project_url,
            image_url:  url::new_unsafe_from_bytes(url_image),
         
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


module yousuinfts::freemint {

    use yousuinfts::nft::{Self};
    use sui::tx_context::{Self, TxContext};
    use std::string::{utf8, String};
    use sui::object::{Self, UID};
    use std::vector;
    use sui::transfer;
    use sui::table::{Self, Table};


    // errors
   
    const ENotAuthorized: u64 = 1; 
    const ENotWhitelist: u64 = 2;
    const EWhitelistExist: u64 = 3;
    const EWhitelistNotExist: u64 = 4;
    const EMaxMintPerAddress: u64 = 5;
    const EMaxMint: u64 = 6;


    
    struct Minted {
        owner: address,
        count: u64,
    }

    struct FreeMint has key {
        id: UID,
        number: u64,
        max_mint: u64,
        mint_per_address: u64,
        is_whitelist: bool,
        whitelist: vector<address>,
        mints: Table<address, u64>,
        randoms: vector<u8>,
        name: String,
        creator: address,
    }

    fun init(ctx: &mut TxContext) {

        let randomlist: vector<u8> = b"11111111111111111111111111111111111111111111111111111111111111111111111111111101111111111111110111111111101111111111111111151115111111111111111111111111111101111111111111111111111111111111111511111111511111111511111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110111111111511111111111111111111111111111511111111111111111111111111111111111111111111111115110111111111111111111111111111111111111111111111101111111111111111111011111111111111511111111111111111111111111111111111151111111111111151111111111111111111111111111111111111511111111111111111111111111111111111111111111111011115111111111111111111111111111151111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110111151111111111111111111111111111111511111151111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111011111111111111151111111111111111111111111111111111111111111111111111111111151111111111111115111110111111111111111111111111511111111111111511111111111111111111111111511111111111111111111111111111111111111111115110111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111101111011111111111111511111151111111111111111111111111111111111111111111115111111111111111111111111111111111111111511111111111101111111111111111111111111111111111111111111111111111111111111111111111111111111111115111151111111111111111110111115111111111115111111111111111111511111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111151111111111111111111111111511111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111151111111111111111111111111115111111111111111111111111111111101111111111111111111111111111111111111111111111111111111111111111111110111111111111111111111111111111111111111111011111111511111111111115111111111111111111151111111111111111111111111111111111111";

        let freemint = FreeMint {
            id: object::new(ctx),
            number: 0,
            is_whitelist: false,
            mint_per_address: 5,
            max_mint: 2000,
            whitelist: vector::empty<address>(),
            mints: table::new(ctx),
            randoms:randomlist,
            name: utf8(b"Free Mint"),
            creator: tx_context::sender(ctx),
        };

       // vector::push_back(&mut freemint.whitelist,@0xbb47b7e40f8e1f7f4cd6f15bdeceaccb2afcc103396fc70456dbc2b63f647679);
        transfer::share_object(freemint)
    }

    public entry fun create_freemint(freemint: &mut FreeMint, name: String, mint_per_address: u64, max_mint: u64, is_whitelist: bool, ctx: &mut TxContext) {
        
        assert!(freemint.creator == tx_context::sender(ctx), ENotAuthorized);
        let newfreemint = FreeMint {
            id: object::new(ctx),
            number: 0,
            is_whitelist: is_whitelist,
            mint_per_address: mint_per_address,
            max_mint: max_mint,
            whitelist: vector::empty<address>(),
            mints: table::new(ctx),
            randoms:vector::empty<u8>(),
            name: name,
            creator: tx_context::sender(ctx),
        };
        transfer::share_object(newfreemint);
    }


    public entry fun update_maxmint(new: u64, freemint: &mut FreeMint, ctx: &mut TxContext){ 
        assert!(freemint.creator == tx_context::sender(ctx), ENotAuthorized);
        freemint.max_mint = new;
    }

    public entry fun update_maxmintperaddress(new: u64, freemint: &mut FreeMint, ctx: &mut TxContext){ 
        assert!(freemint.creator == tx_context::sender(ctx), ENotAuthorized);
        freemint.mint_per_address = new;
    }

    public entry fun updaterandomlist(list: vector<u8>, freemint: &mut FreeMint, ctx: &mut TxContext){
        assert!(freemint.creator == tx_context::sender(ctx), ENotAuthorized);
        freemint.randoms = list;
    }


    public entry fun add_whitelist(freemint: &mut FreeMint, 
     whitelist: vector<address>,
     ctx: &mut TxContext,
    ) {
        assert!(freemint.creator == tx_context::sender(ctx), ENotAuthorized);
        let len = vector::length(&whitelist);
        let i = 0;
        while (i < len) {
            let addr = *vector::borrow(&whitelist, i);
            if(!vector::contains(&freemint.whitelist, &addr)) {
                vector::push_back(&mut freemint.whitelist,addr);
            };
            i = i + 1;
        };
    }

    public entry fun add_address_into_whitelist(freemint: &mut FreeMint, 
     addr_whitelist: address,
     ctx: &mut TxContext,
    ) {
        assert!(freemint.creator == tx_context::sender(ctx), ENotAuthorized);
        assert!(!vector::contains(&freemint.whitelist, &addr_whitelist), EWhitelistExist);
        vector::push_back(&mut freemint.whitelist,addr_whitelist);      
    }

    public entry fun remove_address_whitelist(freemint: &mut FreeMint, 
     addr_whitelist: address,
     ctx: &mut TxContext,
    ) {
        assert!(freemint.creator == tx_context::sender(ctx), ENotAuthorized);
       // assert!(vector::contains(&mint.whitelist, &addr_whitelist), EWHITELIST_EXIST);
        let (check,i) = vector::index_of(&freemint.whitelist,&addr_whitelist);
        assert!(check, EWhitelistNotExist);
        vector::remove(&mut freemint.whitelist,i);  
    }

     public entry fun reset_whitelist(freemint: &mut FreeMint, 
     ctx: &mut TxContext,
    ) {
        assert!(freemint.creator == tx_context::sender(ctx), ENotAuthorized);
        freemint.whitelist = vector::empty();
    }

    fun get_type(number: u8): vector<u8>{

        let type: vector<u8>;
        type = b"pfp";
        if(number == 0) {
            type = b"og";
        };
        if(number == 5) {
            type = b"5";
        };
        type

    }

    public entry fun freemint(freemint: &mut FreeMint, nftinfo: &mut nft::Infomation  ,ctx: &mut TxContext) {
        let sender = tx_context::sender(ctx);
        // check whitelist if is_whitelist
        if(freemint.is_whitelist == true) {
            assert!(
                vector::contains(&freemint.whitelist, &sender),
                ENotWhitelist
            );
        };

        //
        let sender = tx_context::sender(ctx);
        let count: u64 = 0;
        let isadd: bool = true;
        let i = 0;
        if(table::contains(&freemint.mints, sender)) {
            let minted_no = table::borrow(&mut freemint.mints, sender);
            isadd  = false;
            count = *minted_no;
         };

        if(freemint.mint_per_address >0) {
            while( i < freemint.mint_per_address ) {
                i = i+1;
                assert!(freemint.number < freemint.max_mint, EMaxMint);
                assert!(count <= freemint.mint_per_address, EMaxMintPerAddress);
                let index_type = vector::pop_back(&mut freemint.randoms) - 48;
                let type: vector<u8>;
                type = get_type(index_type);
                nft::mint(type,nftinfo,ctx);
                freemint.number = freemint.number+1;
                count = count+1;
            };
        } else {
                assert!(freemint.number < freemint.max_mint, EMaxMint);
                let index_type = vector::pop_back(&mut freemint.randoms) - 48;
                let type: vector<u8>;
                type = get_type(index_type);
                nft::mint(type,nftinfo,ctx);
                freemint.number = freemint.number+1;
                count = count+1;
        };


        if(isadd) {
            table::add(&mut freemint.mints, sender, count);
        } else {
            table::remove(&mut freemint.mints, sender);
            table::add(&mut freemint.mints, sender, count);
        } 
        
    }
}