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
  int cost;

  CartItem._(this.item);

  /// Factory builder to return the concrete implementation
  factory CartItem(Item item, {int count}) => CartItemImpl(item, count: count);

  /// Initializes any dependencies count and other variables
  void onChangeCount(int count) {
    cost = count * item.price;
  }
}

class CartItemImpl extends CartItem {
  CartItemImpl(Item item, {int count})
      : assert(item != null),
        _countBehaviorSubject = count != null
            ? BehaviorSubject<int>(seedValue: count)
            : BehaviorSubject<int>(),
        _costBehaviorSubject = count != null
            ? BehaviorSubject<int>(seedValue: count * item.price)
            : BehaviorSubject<int>(),
        super._(item) {
    initialize();
  }

  final BehaviorSubject<int> _countBehaviorSubject;
  // cost needs to be a behavior subject as its bindable to the UI
  final BehaviorSubject<int> _costBehaviorSubject;

  @override
  int get count => _countBehaviorSubject.value;
  @override
  int get cost => _costBehaviorSubject.value;

  @override
  set count(int value) => _countBehaviorSubject.add(value);
  // TODO: Cost should not be updateable outside the class; how to do this?
  @override
  set cost(int value) => _costBehaviorSubject.add(value);

  // Initializes dependencies between class variables
  void initialize() {
    _countBehaviorSubject.listen(onChangeCount);
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

typedef Widget CartItemConnectorBuilder(int count, int cost);

class CartItemConnector extends StatelessWidget {
  final CartItemConnectorBuilder builder;
  CartItemConnector(this.builder);

  @override
  Widget build(BuildContext context) {
    final cartItem = CartItemProvider.of(context) as CartItemImpl;
    return StreamBuilder(
      stream: cartItem._countBehaviorSubject.stream,
      builder: (context, AsyncSnapshot<int> countSnapshot) => StreamBuilder(
            stream: cartItem._costBehaviorSubject.stream,
            builder: (context, AsyncSnapshot<int> costSnapshot) =>
                builder(countSnapshot.data, costSnapshot.data),
          ),
    );
  }
}
