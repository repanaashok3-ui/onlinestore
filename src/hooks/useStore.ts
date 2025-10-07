import { useState, useEffect } from 'react';
import { supabase, Product, Category, CartItem } from '../lib/supabase';

const getSessionId = () => {
  let sessionId = localStorage.getItem('session_id');
  if (!sessionId) {
    sessionId = crypto.randomUUID();
    localStorage.setItem('session_id', sessionId);
  }
  return sessionId;
};

export const useStore = () => {
  const [products, setProducts] = useState<Product[]>([]);
  const [categories, setCategories] = useState<Category[]>([]);
  const [cartItems, setCartItems] = useState<CartItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [selectedCategory, setSelectedCategory] = useState<string>('all');
  const [searchQuery, setSearchQuery] = useState('');

  const sessionId = getSessionId();

  useEffect(() => {
    fetchCategories();
    fetchProducts();
    fetchCart();
  }, []);

  const fetchCategories = async () => {
    const { data } = await supabase
      .from('categories')
      .select('*')
      .order('name');
    if (data) setCategories(data);
  };

  const fetchProducts = async () => {
    setLoading(true);
    const { data } = await supabase
      .from('products')
      .select('*')
      .order('created_at', { ascending: false });
    if (data) setProducts(data);
    setLoading(false);
  };

  const fetchCart = async () => {
    const { data } = await supabase
      .from('cart_items')
      .select('*')
      .eq('session_id', sessionId);
    if (data) setCartItems(data);
  };

  const addToCart = async (productId: string) => {
    const existingItem = cartItems.find(item => item.product_id === productId);

    if (existingItem) {
      const { data } = await supabase
        .from('cart_items')
        .update({ quantity: existingItem.quantity + 1 })
        .eq('id', existingItem.id)
        .select()
        .single();
      if (data) {
        setCartItems(cartItems.map(item =>
          item.id === data.id ? data : item
        ));
      }
    } else {
      const { data } = await supabase
        .from('cart_items')
        .insert({ session_id: sessionId, product_id: productId, quantity: 1 })
        .select()
        .single();
      if (data) {
        setCartItems([...cartItems, data]);
      }
    }
  };

  const updateCartQuantity = async (itemId: string, quantity: number) => {
    if (quantity <= 0) {
      removeFromCart(itemId);
      return;
    }

    const { data } = await supabase
      .from('cart_items')
      .update({ quantity })
      .eq('id', itemId)
      .select()
      .single();
    if (data) {
      setCartItems(cartItems.map(item =>
        item.id === data.id ? data : item
      ));
    }
  };

  const removeFromCart = async (itemId: string) => {
    await supabase
      .from('cart_items')
      .delete()
      .eq('id', itemId);
    setCartItems(cartItems.filter(item => item.id !== itemId));
  };

  const clearCart = async () => {
    await supabase
      .from('cart_items')
      .delete()
      .eq('session_id', sessionId);
    setCartItems([]);
  };

  const filteredProducts = products.filter(product => {
    const matchesCategory = selectedCategory === 'all' ||
      categories.find(c => c.id === product.category_id)?.name === selectedCategory;
    const matchesSearch = product.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
      product.description.toLowerCase().includes(searchQuery.toLowerCase());
    return matchesCategory && matchesSearch;
  });

  const cartTotal = cartItems.reduce((total, item) => {
    const product = products.find(p => p.id === item.product_id);
    return total + (product?.price || 0) * item.quantity;
  }, 0);

  const cartCount = cartItems.reduce((count, item) => count + item.quantity, 0);

  return {
    products: filteredProducts,
    categories,
    cartItems,
    loading,
    selectedCategory,
    setSelectedCategory,
    searchQuery,
    setSearchQuery,
    addToCart,
    updateCartQuantity,
    removeFromCart,
    clearCart,
    cartTotal,
    cartCount,
    getProductById: (id: string) => products.find(p => p.id === id),
  };
};
