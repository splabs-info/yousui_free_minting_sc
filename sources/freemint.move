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

    fun get_image_url(type:vector<u8>, freemint: &mut FreeMint):vector<u8> {

        let image_url: vector<u8>;
        image_url = b"";

        if(type == b"5") {
            image_url == b"https://files.yousui.io/mint/YouSUI_NFT_TIER5.png";
        };

        if(type == b"4") {
            image_url == b"https://files.yousui.io/mint/YouSUI_NFT_TIER4.png";
        };

        if(type == b"3") {
            image_url == b"https://files.yousui.io/mint/YouSUI_NFT_TIER3.png";
        };

        if(type == b"2") {
            image_url == b"https://files.yousui.io/mint/YouSUI_NFT_TIER2.png";
        };

        if(type == b"1") {
            image_url == b"https://files.yousui.io/mint/YouSUI_NFT_TIER1.png";
        };

         if(type == b"og"){
            image_url = b"https://files.yousui.io/mint/YouSUI_NFT_OGROLE.png";
        };

        if(type == b"pfp"){
   
            if(freemint.number %4 == 0)
            image_url = b"https://files.yousui.io/mint/YouSUI_NFT_PFP4.png";
            if(freemint.number %4 == 1)
            image_url = b"https://files.yousui.io/mint/YouSUI_NFT_PFP1.png";
            if(freemint.number %4 == 2)
            image_url = b"https://files.yousui.io/mint/YouSUI_NFT_PFP2.png";
            if(freemint.number %4 == 3)
            image_url = b"https://files.yousui.io/mint/YouSUI_NFT_PFP3.png";
        };

        image_url
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
                let image_url: vector<u8>;
                type = get_type(index_type);
                image_url = get_image_url(type,freemint);
                nft::mint(type,image_url,nftinfo,ctx);
                freemint.number = freemint.number+1;
                count = count+1;
            };
        } else {
                assert!(freemint.number < freemint.max_mint, EMaxMint);
                let index_type = vector::pop_back(&mut freemint.randoms) - 48;
                let type: vector<u8>;
                type = get_type(index_type);
                let image_url: vector<u8>;
                image_url = get_image_url(type,freemint);
                nft::mint(type,image_url,nftinfo,ctx);
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