import 'package:flutter/widgets.dart';
import 'package:rxdart/rxdart.dart';

class Item {
  final String name;
  final int price;
  Item(this.name, this.price)
      : assert(name != null),
        assert(price != null);
}

abstract class CartItem {
  // Wrappers to return the latest value in the underlying streams
  final Item item;
  int count;
  final int cost;

  /// Factory builder to return the concrete implementation
  factory CartItem(Item item, {int count}) {
    return CartItemImpl(item, count: count);
  }
}

class CartItemImpl implements CartItem {
  CartItemImpl(Item item, {int count})
      : assert(item != null),
        _item = item,
        _countBehaviorSubject = count != null
            ? BehaviorSubject<int>(seedValue: count)
            : BehaviorSubject<int>(),
        _costBehaviorSubject = count != null
            ? BehaviorSubject<int>(seedValue: count * item.price)
            : BehaviorSubject<int>() {
    initialize();
  }

  final Item _item;
  final BehaviorSubject<int> _countBehaviorSubject;
  // cost needs to be a behavior subject as its bindable to the UI
  final BehaviorSubject<int> _costBehaviorSubject;

  Item get item => _item;
  int get count => _countBehaviorSubject.value;
  int get cost => _costBehaviorSubject.value;

  set count(int value) => _countBehaviorSubject.add(value);
  // Cost cannot be updated outside the class
  set _cost(int value) => _costBehaviorSubject.add(value);

  // Initializes dependencies between class variables
  void initialize() {
    _countBehaviorSubject.listen((count) => _cost = item.price * count);
  }
}

class CartItemProvider extends InheritedWidget {
  const CartItemProvider({
    Key key,
    @required this.cartItem,
    @required Widget child,
  })  : assert(cartItem != null),
        assert(child != null),
        super(key: key, child: child);

  final CartItem cartItem;

  static CartItem of(BuildContext context) =>
      (context.inheritFromWidgetOfExactType(CartItemProvider)
              as CartItemProvider)
          .cartItem;

  /// Returns false as the cart item is immutable, so never changes
  @override
  bool updateShouldNotify(CartItemProvider old) => false;
}

class CartItemCountConnector extends StatelessWidget {
  final Function(int) builder;
  CartItemCountConnector(this.builder);

  @override
  Widget build(BuildContext context) {
    final cartItem = CartItemProvider.of(context) as CartItemImpl;
    return StreamBuilder(
        stream: cartItem._countBehaviorSubject.stream,
        builder: (context, AsyncSnapshot<int> snapshot) =>
            builder(snapshot.data));
  }
}

class CartItemCostConnector extends StatelessWidget {
  final Function(int) builder;
  CartItemCostConnector(this.builder);

  @override
  Widget build(BuildContext context) {
    final cartItem = CartItemProvider.of(context) as CartItemImpl;
    return StreamBuilder(
        stream: cartItem._costBehaviorSubject.stream,
        builder: (context, AsyncSnapshot<int> snapshot) =>
            builder(snapshot.data));
  }
}
