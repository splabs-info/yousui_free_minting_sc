module yousuinfts::nft {
    use sui::url::{Self, Url};
    use std::string::{utf8, String};
    use sui::object::{Self, ID, UID};
    use sui::event;
    use sui::transfer;
    use sui::tx_context::{Self,sender, TxContext};
    use sui::package;
    use sui::display;

    const ENOT_AUTHORIZED: u64 = 1; 

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

  
    public  fun mint( type: vector<u8>, info: &mut Infomation,
        ctx: &mut TxContext
    ) {
        let sender = tx_context::sender(ctx);

        let url_image: vector<u8>;
        let description: String;

        url_image = b"";
        description = utf8(b"Description here");

        if(type == b"og"){
            url_image = b"https://files.yousui.io/mint-beta/YouSUI_NFT_OGROLE.png";
            description = info.description_og;
        };

        if(type == b"pfp"){
            description = info.description_pfp;
            if(info.mint_index %4 == 0)
            url_image = b"https://files.yousui.io/mint-beta/YouSUI_NFT_PFP4.png";
            if(info.mint_index %4 == 1)
            url_image = b"https://files.yousui.io/mint-beta/YouSUI_NFT_PFP1.png";
            if(info.mint_index %4 == 2)
            url_image = b"https://files.yousui.io/mint-beta/YouSUI_NFT_PFP2.png";
            if(info.mint_index %4 == 3)
            url_image = b"https://files.yousui.io/mint-beta/YouSUI_NFT_PFP3.png";

        };
        if(type == b"1") {
            description = info.description_tier2;
            url_image = b"https://files.yousui.io/mint-beta/YouSUI_NFT_TIER2.png";
        };
        if(type == b"2") {
            description = info.description_tier2;
            url_image = b"https://files.yousui.io/mint-beta/YouSUI_NFT_TIER2.png";
        };

        if(type == b"3") {
            description = info.description_tier3;
            url_image = b"https://files.yousui.io/mint-beta/YouSUI_NFT_TIER3.png";
        };

        if(type == b"4") {
            description = info.description_tier4;
            url_image = b"https://files.yousui.io/mint-beta/YouSUI_NFT_TIER4.png";
        };

        if(type == b"5") {
            description = info.description_tier5;
            url_image = b"https://files.yousui.io/mint-beta/YouSUI_NFT_TIER5.png";
        };
        
        let nft = YOUSUINFT {
            id: object::new(ctx),
            name: utf8(b"YOUSUI-NFT"),
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
        assert!(info.creator == tx_context::sender(ctx), ENOT_AUTHORIZED);
        info.description_og = new_description
    }

    public entry fun update_description_pfp(
        info: &mut Infomation,
        new_description: String,
        ctx: &mut TxContext
    ) {
        assert!(info.creator == tx_context::sender(ctx), ENOT_AUTHORIZED);
        info.description_pfp = new_description
    }


    public entry fun update_description_tier1(
        info: &mut Infomation,
        new_description: String,
        ctx: &mut TxContext
    ) {
        assert!(info.creator == tx_context::sender(ctx), ENOT_AUTHORIZED);
        info.description_tier1 = new_description
    }

    public entry fun update_description_tier2(
        info: &mut Infomation,
        new_description: String,
        ctx: &mut TxContext
    ) {
        assert!(info.creator == tx_context::sender(ctx), ENOT_AUTHORIZED);
        info.description_tier2 = new_description
    }

    public entry fun update_description_tier3(
        info: &mut Infomation,
        new_description: String,
        ctx: &mut TxContext
    ) {
        assert!(info.creator == tx_context::sender(ctx), ENOT_AUTHORIZED);
        info.description_tier3 = new_description
    }

    public entry fun update_description_tier4(
        info: &mut Infomation,
        new_description: String,
        ctx: &mut TxContext
    ) {
        assert!(info.creator == tx_context::sender(ctx), ENOT_AUTHORIZED);
        info.description_tier4 = new_description
    }

    public entry fun update_description_tier5(
        info: &mut Infomation,
        new_description: String,
        ctx: &mut TxContext
    ) {
        assert!(info.creator == tx_context::sender(ctx), ENOT_AUTHORIZED);
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
    use sui::object::{Self, UID};
    use std::vector;
    use sui::transfer;
    use sui::table::{Self, Table};

    const MAX_MINT_PER_ADDRESS: u64 = 5;
    const MAX_MINT: u64 = 2000;

    // errors
   
    const ENOT_AUTHORIZED: u64 = 1; 
    const ENOT_WHITELIST: u64 = 2;
    const EWHITELIST_EXIST: u64 = 3;
    const EWHITELIST_NOTEXIST: u64 = 4;
    const EMAX_MINT_PER_ADDRESS: u64 = 5;
    const EMAX_MINT: u64 = 6;


    
    struct Minted {
        owner: address,
        count: u64,
    }

    struct FreeMint has key {
        id: UID,
        number: u64,
        max_number: u64,
        whitelist: vector<address>,
        mints: Table<address, u64>,
        randoms: vector<u8>,
        creator: address,
    }

    fun init(ctx: &mut TxContext) {

        let randomlist: vector<u8> = b"10111111111111151011110111011111011501101111110111511110111511111015111110111151111151111511115110101510511111111110111111111111110510101151511511115111101111111015111005111151110115115101111101151111051011115111115110115101511111110151111100111111101510155111151110115501115111001111511111111551150151111111111115115011110011110101111111111101151511115155115111110101111111101110111111111511111111111111111111501111511111111110111101111100511111011115111111151511111011101111101115111111111111111111110115110111111100111551105011111111111511111111111111110111051111111111111111055111115111111111511150115111151111111111511111111151011510011111511051511501551111151111151110511111010111115511111111111111111551111111111011115110115011011111111551011111501111111111111111111111111151510051111515511101511111510111111011115110511111111111111115011111111151151151511001011015011105155110111111111111115111155110101111501511110511111115101111111511151111110111111110505051011115501111101110111111111011011101511151110111011111111111111111011111110111551111115101110111111111111111111151111100511111051111111511011101111511111110015115111151111111111011111011111011101111511155011511111011150101111111111510111111111105155111151111111110101050111111111111111111511151501010011110111011101150100511115501111111111111111111011111111111111511110551111111111111511051151111515101101150511110111111111011111111111111111155111111111510111111111111111111111111111111101115101115111100111111111115115111151110110111551111001111110111111115015111111111151111151110155111151155151111111115110115111111011100110111011101115511111100111011151115111110111110110511111111015111111111111115511101515011101111110001110011011110110111111111011111115501110155011111110110111110111111010111111151115011551111551511115510115101011511111111115111110111101151111111105551111111111150111111111151511151111111111511011111511515111111110101151111111115111115111111100101010105101001111011100011111111111111011111111111551511111151";

        let freemint = FreeMint {
            id: object::new(ctx),
            number: 0,
            max_number: MAX_MINT,
            whitelist: vector::empty<address>(),
            mints: table::new(ctx),
            randoms:randomlist,
            creator: tx_context::sender(ctx),
        };

        vector::push_back(&mut freemint.whitelist,@0xbb47b7e40f8e1f7f4cd6f15bdeceaccb2afcc103396fc70456dbc2b63f647679);
        vector::push_back(&mut freemint.whitelist,@0x0ad2f84b705b26479f0a0a20d142db298308b39117bc7b0cbf44aeae6312ed5f);

       transfer::share_object(freemint)
    }


    public entry fun add_whitelist(freemint: &mut FreeMint, 
     whitelist: vector<address>,
     ctx: &mut TxContext,
    ) {
        assert!(freemint.creator == tx_context::sender(ctx), ENOT_AUTHORIZED);
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
        assert!(freemint.creator == tx_context::sender(ctx), ENOT_AUTHORIZED);
        assert!(!vector::contains(&freemint.whitelist, &addr_whitelist), EWHITELIST_EXIST);
        vector::push_back(&mut freemint.whitelist,addr_whitelist);      
    }

    public entry fun remove_address_whitelist(freemint: &mut FreeMint, 
     addr_whitelist: address,
     ctx: &mut TxContext,
    ) {
        assert!(freemint.creator == tx_context::sender(ctx), ENOT_AUTHORIZED);
       // assert!(vector::contains(&mint.whitelist, &addr_whitelist), EWHITELIST_EXIST);
        let (check,i) = vector::index_of(&freemint.whitelist,&addr_whitelist);
        assert!(check, EWHITELIST_NOTEXIST);
        vector::remove(&mut freemint.whitelist,i);  
    }

     public entry fun reset_whitelist(freemint: &mut FreeMint, 
     ctx: &mut TxContext,
    ) {
        assert!(freemint.creator == tx_context::sender(ctx), ENOT_AUTHORIZED);
        vector::destroy_empty(freemint.whitelist);   
    }

    public entry fun freemint(freemint: &mut FreeMint, nftinfo: &mut nft::Infomation  ,ctx: &mut TxContext) {
        let sender = tx_context::sender(ctx);
        assert!(
            vector::contains(&freemint.whitelist, &sender),
            ENOT_WHITELIST
        );
        assert!(freemint.number < MAX_MINT, EMAX_MINT);
        let sender = tx_context::sender(ctx);
        let count: u64 = 0;
        let isadd: bool = true;
        if(table::contains(&freemint.mints, sender)) {
        let minted_no = table::borrow(&mut freemint.mints, sender);
        isadd  = false;
        count = *minted_no;
        assert!(count < MAX_MINT_PER_ADDRESS, EMAX_MINT_PER_ADDRESS);
         };
        let index_type = vector::pop_back(&mut freemint.randoms) - 48;
        let type: vector<u8>;
        type = b"pfp";
        if(index_type == 0) {
            type = b"og";
        };
        if(index_type == 5) {
            type = b"5";
        };

        nft::mint(type,nftinfo,ctx);
        freemint.number = freemint.number+1;
        if(isadd) {
                table::add(&mut freemint.mints, sender, count+1);
        } else {
            table::remove(&mut freemint.mints, sender);
            table::add(&mut freemint.mints, sender, count+1);
        }  
    }
}